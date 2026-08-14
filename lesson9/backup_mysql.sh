#!/bin/bash

set -e

DB_NAME="appdb"
BACKUP_DIR="/opt/mysql_backup"
STORE="rsync://192.168.56.20/mysql"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

echo "Waiting for rsync store..."

for i in {1..30}; do
    if nc -z 192.168.56.20 873 2>/dev/null; then
        break
    fi

    sleep 2
done

if ! nc -z 192.168.56.20 873 2>/dev/null; then
    echo "ERROR: rsync store is unavailable"
    exit 1
fi

BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql"

echo "========================================"
echo "MySQL backup started: $(date)"
echo "========================================"

mkdir -p "$BACKUP_DIR"

echo "Creating dump..."

mysqldump \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    --databases "$DB_NAME" \
    > "$BACKUP_FILE"

echo "Backup created:"
echo "$BACKUP_FILE"

echo "Synchronizing with store..."

rsync -av "$BACKUP_DIR/" "$STORE/"

echo "Synchronization completed."

echo "Backup files currently available:"

ls -lh "$BACKUP_DIR"

echo "========================================"
echo "MySQL backup completed: $(date)"
echo "========================================"
