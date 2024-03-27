#!/bin/bash

# PostgreSQL settings
DB_NAME="root_db"
DB_USER="${POSTGRES_USER}"
DB_PORT="5433"
DATE=$(date +"%Y%m%d%H%M%S")
BACKUP_DIR_LOCAL="/media/backup/nocodb_bckp/short_term_bckp"
BACKUP_DIR_DISTANT="/media/share/dbgi/nocodb_bckp/short_term_bckp"
LOG_FILE="/media/backup/nocodb_bckp/short_term_bckp/bckp.log"
BACKUP_FILE_LOCAL="${BACKUP_DIR_LOCAL}/${DB_NAME}_${DATE}.sql"
BACKUP_FILE_DISTANT="${BACKUP_DIR_DISTANT}/${DB_NAME}_${DATE}.sql"
RETAIN_BACKUPS=24

# Redirect all output to the log file
exec &>> "$LOG_FILE"

# Enable immediate exit on error
set -e

# Perform backup using psql
psql -U "$DB_USER" -d "$DB_NAME" -p "$DB_PORT" -c "COPY (SELECT * FROM your_table) TO STDOUT" > "$BACKUP_FILE_LOCAL"
psql -U "$DB_USER" -d "$DB_NAME" -p "$DB_PORT" -c "COPY (SELECT * FROM your_table) TO STDOUT" > "$BACKUP_FILE_DISTANT"

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: $BACKUP_FILE_LOCAL"
    echo "Backup completed successfully: $BACKUP_FILE_DISTANT"
else
    echo "Backup failed"
    exit 1
fi

# Keep only the latest backups
cleanup_backups() {
    local backup_dir="$1"
    if [ -n "$(ls -A "$backup_dir")" ]; then
        ls -dt "$backup_dir"/* | tail -n +"$((RETAIN_BACKUPS+1))" | xargs rm -rf
    fi
}

cleanup_backups "$BACKUP_DIR_LOCAL"
cleanup_backups "$BACKUP_DIR_DISTANT"
