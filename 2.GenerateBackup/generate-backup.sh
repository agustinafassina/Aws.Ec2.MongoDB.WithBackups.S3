set -euo pipefail

# --- Configuration ---
BACKUP_BASE="/home/ubuntu/mongodb_backups"
S3_BUCKET="s3-backup-name"
S3_PREFIX="backuptest"
LOCK_FILE="/tmp/mongodb-backup.lock"
LOG_FILE="/var/log/mongodb-backup.log"

# --- Helpers ---
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

cleanup() {
  if [[ -f "$LOCK_FILE" ]]; then
    rm -f "$LOCK_FILE"
    log "Lock released."
  fi
}

trap cleanup EXIT

# --- Main ---
NOW=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE/$NOW"
USE_GZIP=false

[[ "${1:-}" == "--gzip" ]] && USE_GZIP=true

# Prevent overlapping runs (e.g. cron)
if [[ -f "$LOCK_FILE" ]]; then
  log "ERROR: Another backup is running (lock file exists). Exiting."
  exit 1
fi
touch "$LOCK_FILE"
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
