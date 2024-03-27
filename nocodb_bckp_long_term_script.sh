#!/bin/bash

# Variables
DATE=$(date +"%Y%m%d%H%M%S")
BACKUP_DIR_LOCAL="/media/backup/nocodb_bckp/long_term_bckp"
BACKUP_DIR_DISTANT="/media/share/dbgi/nocodb_bckp/long_term_bckp"
LOG_FILE="/media/backup/nocodb_bckp/long_term_bckp/bckp.log"
RETAIN_BACKUPS=2

# Redirect all output to the log file
exec &>> "$LOG_FILE"

# Enable immediate exit on error
set -e

mkdir -p "${BACKUP_DIR_LOCAL}/${DATE}"
mkdir -p "${BACKUP_DIR_DISTANT}/${DATE}"

# Perform backup
tar -czvf "${BACKUP_DIR_LOCAL}/${DATE}/backup.tar.gz" -C "$POSTGRES_DIR" .
#tar -czvf "${BACKUP_DIR_DISTANT}/${DATE}/backup.tar.gz" -C "$POSTGRES_DIR" .

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: ${BACKUP_DIR_LOCAL}/${DATE}/backup.tar.gz"
    echo "Backup completed successfully: ${BACKUP_DIR_DISTANT}/${DATE}/backup.tar.gz"
else
    echo "Backup failed"
    exit 1
fi

# Keep only the latest backups
cleanup_backups() {
    local backup_dir="$1"
    echo "Cleaning up backups in directory: $backup_dir"
    if [ -n "$(ls -A "$backup_dir")" ]; then
        echo "Old backups found:"
        ls -dt "$backup_dir"/*
        echo "Deleting old backups..."
        ls -dt "$backup_dir"/* | tail -n +"$((RETAIN_BACKUPS+1))" | xargs rm -rf
        echo "Cleanup complete"
    else
        echo "No old backups found"
    fi
}

cleanup_backups "$BACKUP_DIR_LOCAL"
cleanup_backups "$BACKUP_DIR_DISTANT"
