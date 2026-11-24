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
# mongorestore connects to a running server, so mongod must stay UP during the restore.
# --drop replaces each restored collection; no need to touch the data directory.
log "Restore from: $backup_path"
log "MongoDB: $mongo_host:$mongo_port"

if ! systemctl is-active --quiet mongod; then
  log "mongod is not running. Starting it..."
  sudo systemctl start mongod
fi

log "Restoring from backup..."
MONGORESTORE_OPTS=(--host="$mongo_host" --port="$mongo_port" --dir="$backup_path" --drop)
if [[ -n "$mongo_db_name" ]]; then
  MONGORESTORE_OPTS+=(--nsInclude="${mongo_db_name}.*")
  log "Restoring only database: $mongo_db_name"
fi
if [[ "$use_gzip" == "true" || "$use_gzip" == "1" ]]; then
  MONGORESTORE_OPTS+=(--gzip)
fi
mongorestore "${MONGORESTORE_OPTS[@]}"

log "Restore complete."
