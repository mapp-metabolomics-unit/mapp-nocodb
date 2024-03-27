#!/bin/bash

# Variables
DATE=$(date +"%Y%m%d%H%M%S")
POSTGRES_DIR="/docker/nocodb/postgres"
BACKUP_DIR_LOCAL="/media/backup/nocodb_bckp/short_term_bckp/${DATE}"
BACKUP_DIR_DISTANT="/media/share/dbgi/nocodb_bckp/short_term_bckp/${DATE}"
LOG_FILE="/media/backup/nocodb_bckp/short_term_bckp/bckp.log"
RETAIN_BACKUPS=24

# Redirect all output to the log file
exec &>> "$LOG_FILE"

# Enable immediate exit on error
set -e

mkdir $BACKUP_DIR_LOCAL
mkdir $BACKUP_DIR_DISTANT

# Perform backup
tar -czvf "${BACKUP_DIR_LOCAL}/backup.tar.gz" -C $POSTGRES_DIR
tar -czvf "${BACKUP_DIR_DISTANT}/backup.tar.gz" -C $POSTGRES_DIR

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: ${BACKUP_DIR_LOCAL}/backup.tar.gz"
    echo "Backup completed successfully: ${BACKUP_DIR_DISTANT}/backup.tar.gz"
else
    echo "Backup failed"
    exit 1
fi

# Keep only the latest backups
cleanup_backups() {
    local backup_dir="$1"
    if [ -n "$(ls -A "$backup_dir")" ]; then
        ls -dt "$backup_dir"/* | tail -n +"$((RETAIN_BACKUPS+2))" | xargs rm -rf
    fi
}

cleanup_backups "$BACKUP_DIR_LOCAL"
cleanup_backups "$BACKUP_DIR_DISTANT"
