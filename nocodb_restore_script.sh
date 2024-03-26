#!/bin/bash

# Function to display help and usage instructions
show_help() {
    echo "Usage: $0 [backup directory] <timestamp>"
    echo
    echo "This script restores a backup of the specified directory from a given timestamp."
    echo
    echo "Arguments:"
    echo "  backup directory  The directory where backups are stored."
    echo "                    If not provided, defaults to '/backup/directus_bckp/short_term_bckp'."
    echo "  timestamp         The timestamp of the backup to restore. Format: YYYYMMDDHHMMSS"
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message and exit."
    echo
    echo "Example:"
    echo "  $0 /custom/backup/dir 20240205120240"
    echo
    echo "In this example, the script will attempt to restore the backup from '/custom/backup/dir'"
    echo "that was created at the timestamp 20240205120240."
}

# Default backup directory (used if no specific directory is provided)
DEFAULT_BACKUP_DIR="/backup/directus_bckp/short_term_bckp"

# Original directory to restore
ORIGINAL_DIR="/prog/directus/database"

# Check for help option
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Check if the backup directory argument is provided
if [ -z "$1" ]; then
    echo "Error: Backup directory argument is required."
    echo
    show_help
    exit 1
fi

# Use the first argument as the backup directory
BACKUP_DIR="$1"

# Check if the timestamp argument is provided
if [ -z "$2" ]; then
    echo "Error: Timestamp argument is required."
    echo
    show_help
    exit 1
fi

# Specify the timestamp from the command-line argument
RESTORE_TIMESTAMP="$2"

# Backup archive file name
BACKUP_ARCHIVE="backup.tar.gz"

# Check if the backup exists
if [ -f "$BACKUP_DIR/$RESTORE_TIMESTAMP/$BACKUP_ARCHIVE" ]; then

    # Ask for confirmation before clearing the original directory
    read -p "Are you sure you want to clear the original directory and restore the backup? Type '$RESTORE_TIMESTAMP' to confirm: " CONFIRMATION
    if [ "$CONFIRMATION" = "$RESTORE_TIMESTAMP" ]; then
        # Clear the original directory
        rm -rf "$ORIGINAL_DIR"/*

        # Extract the backup to the original directory
        tar -xzf "$BACKUP_DIR/$RESTORE_TIMESTAMP/$BACKUP_ARCHIVE" -C "$ORIGINAL_DIR"

        echo "Directory $ORIGINAL_DIR restored to version $RESTORE_TIMESTAMP"
    else
        echo "Confirmation failed. Restore process aborted."
        exit 1
    fi
else
    echo "Backup version $RESTORE_TIMESTAMP not found."
    exit 1
fi
