#!/bin/bash

# Variables
DATE=$(date +"%Y%m%d%H%M%S")
BACKUP_DIR_LOCAL="/media/backup/nocodb_bckp/long_term_bckp"
BACKUP_DIR_DISTANT="/media/share/dbgi/nocodb_bckp/long_term_bckp"
LOG_FILE="/media/backup/nocodb_bckp/long_term_bckp/bckp.log"

# Redirect all output to the log file
exec &>> "$LOG_FILE"

# Enable immediate exit on error
set -e

mkdir "${BACKUP_DIR_LOCAL}/${DATE}"
mkdir "${BACKUP_DIR_DISTANT}/${DATE}"

# Perform backup
tar -czvf "${BACKUP_DIR_LOCAL}/${DATE}/backup.tar.gz" -C "$POSTGRES_DIR" .
tar -czvf "${BACKUP_DIR_DISTANT}/${DATE}/backup.tar.gz" -C "$POSTGRES_DIR" .

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: ${BACKUP_DIR_LOCAL}/${DATE}/backup.tar.gz"
    echo "Backup completed successfully: ${BACKUP_DIR_DISTANT}/${DATE}/backup.tar.gz"
else
    echo "Backup failed"
    exit 1
fi

# Keep only the latest 52 backups
if [ -n "$(ls -A "$BACKUP_DIR_LOCAL")" ]; then
    ls -dt "$BACKUP_DIR_LOCAL"/* | tail -n +4 | xargs rm -rf
fi

if [ -n "$(ls -A "$BACKUP_DIR_DISTANT")" ]; then
    ls -dt "$BACKUP_DIR_DISTANT"/* | tail -n +4 | xargs rm -rf
fi