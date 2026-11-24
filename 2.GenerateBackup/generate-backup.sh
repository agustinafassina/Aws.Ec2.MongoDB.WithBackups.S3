#!/bin/bash
set -euo pipefail

# --- Configuration ---
BACKUP_BASE="/home/ubuntu/mongodb_backups"
S3_BUCKET="s3-backup-name"
S3_PREFIX="backuptest"
LOCK_FILE="/tmp/mongodb-backup.lock"
LOG_FILE="/var/log/mongodb-backup.log"

# --- Logging ---
# Send all output (including mongodump / aws errors) to the terminal and the log file.
# The script owns the log file, so cron must NOT redirect into it again.
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# --- Main ---
NOW=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE/$NOW"
USE_GZIP=false

[[ "${1:-}" == "--gzip" ]] && USE_GZIP=true

# Prevent overlapping runs (e.g. cron). flock is released automatically when the
# script exits (even if killed), so a stale lock can never block future backups
# and a second run never removes the lock held by the first one.
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
  log "ERROR: Another backup is running (lock held on $LOCK_FILE). Exiting."
  exit 1
fi
log "Backup started (PID $$)."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Run mongodump
log "Running mongodump..."
if $USE_GZIP; then
  mongodump --out "$BACKUP_DIR" --gzip
else
  mongodump --out "$BACKUP_DIR"
fi
log "mongodump completed."

# Upload to S3 (only delete local copy after success)
log "Uploading to s3://$S3_BUCKET/$S3_PREFIX/..."
if aws s3 cp "$BACKUP_BASE" "s3://$S3_BUCKET/$S3_PREFIX/" --recursive; then
  log "Upload completed."
  rm -rf "$BACKUP_BASE"
  log "Local backup removed."
else
  log "ERROR: S3 upload failed. Local backup kept at $BACKUP_BASE"
  exit 1
fi

log "Backup finished successfully."
exit 0
