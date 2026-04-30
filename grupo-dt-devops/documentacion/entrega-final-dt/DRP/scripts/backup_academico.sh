#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/var/backups/postgresql"
DATE="$(date +%F_%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/academico_${DATE}.sql"

mkdir -p "$BACKUP_DIR"
sudo -u postgres pg_dump academico > "$BACKUP_FILE"
echo "Backup completado: $BACKUP_FILE"
