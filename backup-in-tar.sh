#!/bin/bash

# Define variables
SOURCE_FOLDER="/home/opc/opc/seperate-mysql-db-bk"
ARCHIVE_NAME="backup_mysql.tar"
DESTINATION_FOLDER="/home/opc/opc/seperate-mysql-db-bk/backup_tar"

# Archive the folder
tar -czf $DESTINATION_FOLDER/$ARCHIVE_NAME -C $SOURCE_FOLDER .
