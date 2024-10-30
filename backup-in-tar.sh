#!/bin/bash

# Define variables
SOURCE_FOLDER="/path/of/backups"                  # Enter the complete path of parent directory which is storing all database backup in seperate folder
                                                  # means if there is 2 database -> create 2 folder with the EXACT name of database and store dump into 
                                                  # relvant directory
ARCHIVE_NAME="backup_mysql.tar"
DESTINATION_FOLDER="$HOME/backup-in-tar"                # DESTINATION_FOLDER="/home/opc/opc/seperate-mysql-db-bk/backup_tar"


# making downloads directory if not exist 
DOWNLOAD_DIR="$HOME/backup-in-tar"

# Check if the directory exists
if [ ! -d "$DOWNLOAD_DIR" ]; then
    # If not, create the directory
    mkdir "$DOWNLOAD_DIR"
    echo "Directory 'download' created at $HOME"
else
    echo "Directory 'backup-in-tar' already exists at $HOME"
fi

# Archive the folder
tar -czf $DESTINATION_FOLDER/$ARCHIVE_NAME -C $SOURCE_FOLDER .
