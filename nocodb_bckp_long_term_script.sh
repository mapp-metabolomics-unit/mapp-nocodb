#!/bin/bash

# Backup directory
BACKUP_DIR_LOCAL="/media/backup/nocodb_bckp/long_term_bckp"
BACKUP_DIR_DISTANT="/media/share/dbgi/nocodb_bckp/long_term_bckp"
LOG_FILE="/media/backup/nocodb_bckp/long_term_bckp/bckp.log"

# Local directory to backup
SOURCE_DIR="/docker/nocodb/postgres"

# Create a timestamp with the format YYYYMMDDHHMMSS
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Redirect all output to the log file
exec &>> "$LOG_FILE"

# Enable immediate exit on error
set -e

# Create backups
tar -czf "$BACKUP_DIR_LOCAL/$TIMESTAMP.tar.gz" -C "$SOURCE_DIR" .
tar -czf "$BACKUP_DIR_DISTANT/$TIMESTAMP.tar.gz" -C "$SOURCE_DIR" .


# Keep only the latest 52 backups
if [ -n "$(ls -A "$BACKUP_DIR_LOCAL")" ]; then
    ls -dt "$BACKUP_DIR_LOCAL"/* | tail -n +54 | xargs rm -rf
fi
