#!/bin/bash
set -euo pipefail

# --- Configuration ---
backup_path="${BACKUP_PATH:-/backup}"
mongo_host="${MONGO_HOST:-localhost}"
mongo_port="${MONGO_PORT:-27017}"
mongo_db_name="${MONGO_DB_NAME:-}"   # Optional: restore single DB; leave empty for all
use_gzip="${RESTORE_GZIP:-false}"    # Set to true if backup was created with --gzip

# --- Helpers ---
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# --- Validations ---
if [[ ! -d "$backup_path" ]]; then
  log "ERROR: Backup path does not exist: $backup_path"
  log "Usage: BACKUP_PATH=/path/to/backup ./restore-backup.sh"
  exit 1
fi

# --- Main ---
log "Restore from: $backup_path"
log "MongoDB: $mongo_host:$mongo_port"

# Step 1: Stop MongoDB
log "Stopping MongoDB..."
sudo systemctl stop mongod || true

# Step 2: Clean existing data
log "Cleaning existing data..."
sudo rm -rf /var/lib/mongo/*

# Step 3: Restore
log "Restoring from backup..."
MONGORESTORE_OPTS=(--host="$mongo_host" --port="$mongo_port" --dir="$backup_path" --drop)
[[ -n "$mongo_db_name" ]] && MONGORESTORE_OPTS+=(--db="$mongo_db_name")
[[ "$use_gzip" == "true" || "$use_gzip" == "1" ]] && MONGORESTORE_OPTS+=(--gzip)
mongorestore "${MONGORESTORE_OPTS[@]}"

# Step 4: Start MongoDB
log "Starting MongoDB..."
sudo systemctl start mongod

log "Restore complete."
