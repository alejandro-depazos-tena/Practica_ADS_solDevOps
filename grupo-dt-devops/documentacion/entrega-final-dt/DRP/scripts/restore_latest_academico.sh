#!/usr/bin/env bash
set -euo pipefail

latest_dump=$(ls -1t /var/backups/postgresql/academico_*.sql 2>/dev/null | head -n 1)

if [ -z "${latest_dump:-}" ]; then
  echo "No hay backups disponibles en /var/backups/postgresql"
  exit 1
fi

sudo -u postgres dropdb --if-exists academico_restore
sudo -u postgres createdb academico_restore
sudo -u postgres psql -d academico_restore -f "$latest_dump"
echo "Restauracion completada en academico_restore usando $latest_dump"
