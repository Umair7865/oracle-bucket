#!/bin/bash

# Define variables
ARCHIVE_NAME="backup_mysql.tar.gz"
DESTINATION_FOLDER="$HOME/backup-in-tar"          # DESTINATION_FOLDER="/home/opc/opc/seperate-mysql-db-bk/backup_tar"
SOURCE_FOLDER="$HOME/MySQL"        # Enter the complete path of parent directory which is storing all database backup in seperate folder
                                                  # means if there is 2 database -> create 2 folder with the EXACT name of database and store dump into 
                                                  # relvant directory

# making downloads directory if not exist 
MySQL_DIR="$HOME/MySQL"

# Check if the directory exists
if [ ! -d "$MySQL_DIR" ]; then
    # If not, create the directory
    mkdir "$MySQL_DIR"
    echo "Directory 'MySQL' created at $HOME"
else
    echo "Directory 'MySQL' already exists at $HOME"
fi


echo "Please organize your backup directory as follows:"
echo "
$HOME/MySQL
│
├── database1/
│   └── dump.sql       # Backup file for database1
│
├── database2/
│   └── dump.sql       # Backup file for database2
│
└── database3/
    └── dump.sql       # Backup file for database3
"

echo "Note:"
echo "1. Place each database directory under $HOME/MySQL"
echo "2. Each directory must be named exactly after the corresponding database (e.g., database1, database2)."
echo "3. Place each dump.sql file inside its respective database folder."
echo " "
echo " "



# Prompt for confirmation before proceeding
read -p "Arrange the files as shown in above diagram than run this script to create TAR file. After arranging database path as per diagram confirm with (yes/no): " confirmation

if [[ "$confirmation" != "yes" ]]; then
    echo " "
    echo "Take your Time and Arrange it Accordingly."
    echo " "
    exit 1
fi


# making downloads directory if not exist 
BACKUP_TAR="$HOME/backup-in-tar"

# Check if the directory exists
if [ ! -d "$BACKUP_TAR" ]; then
    # If not, create the directory
    mkdir "$BACKUP_TAR"
    echo " "
    echo "Directory 'backup-in-tar' created at $HOME"
    echo " "
else
    echo " "
    echo "Directory 'backup-in-tar' already exists at $HOME"
    echo " "
fi

# Archive the folder
tar -czf $DESTINATION_FOLDER/$ARCHIVE_NAME -C $SOURCE_FOLDER .

echo " "
echo " Congratulations!!! TAR file of your database has been created under directory $HOME/backup-in-tar"
echo " "