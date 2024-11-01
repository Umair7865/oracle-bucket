#!/bin/bash

# Function for backup-in-tar.sh
backup_in_tar() {

# Define variables
ARCHIVE_NAME="backup_mysql.tar.gz"
DESTINATION_FOLDER="$HOME/backup-in-tar"          # DESTINATION_FOLDER="/home/opc/opc/seperate-mysql-db-bk/backup_tar"
SOURCE_FOLDER="$HOME/MySQL"                       # Enter the complete path of parent directory which is storing all database backup in seperate folder
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
tar -cf $DESTINATION_FOLDER/$ARCHIVE_NAME -C $SOURCE_FOLDER .

echo " "
echo " Congratulations!!! TAR file of your database has been created under directory $HOME/backup-in-tar"
echo " "


}

# Declare global variable
BUCKET_NAME=""

set_bucket_name() {
    read -p "Enter the bucket name: " BUCKET_NAME
}


# Function for upload-to-bucket.sh
upload_to_bucket() {

# Variables
# NAMESPACE=$(oci os ns get --query 'data' --raw-output)
# Prompt for bucket name if not already set
    if [ -z "$BUCKET_NAME" ]; then
        set_bucket_name
    fi
#BUCKET_NAME="<enter name of bucket>"                                                    # Replace with your bucket name
OBJECT_NAME="latest_database_backup_$(date +\%F__\%H_hour-\%M_min).tar"                 # Name to use when storing the object in the bucket
FILE_PATH="$HOME/backup-in-tar/backup_mysql.tar.gz"           # Path to the file on your local system

# Upload the file
oci os object put --bucket-name $BUCKET_NAME --name $OBJECT_NAME --file $FILE_PATH

# Check if the upload was successful
if [ $? -eq 0 ]; then
    echo "File '$FILE_PATH' uploaded to bucket '$BUCKET_NAME' as '$OBJECT_NAME' ."
else
    echo "Failed to upload file '$FILE_PATH'."
fi

echo ""
}





# Function for download-and-restore.sh
download_and_restore() {
# Variables
NAMESPACE=$(oci os ns get --query 'data' --raw-output)
#BUCKET_NAME="<Bucket-Name-Here>"  # Replace with your bucket name
LOCAL_DOWNLOAD_PATH="$HOME/downloads"  # Directory where the tar file will be downloaded
EXTRACT_PATH="$HOME/downloads"  # Directory where the tar file will be extracted
MYSQL_USER="root"  # Replace with your MySQL username
MYSQL_PASSWORD="root123"  # Replace with your MySQL password

# making downloads directory if not exist 
DOWNLOAD_DIR="$HOME/downloads"
echo ""
# Check if the directory exists
if [ ! -d "$DOWNLOAD_DIR" ]; then
    # If not, create the directory
    mkdir "$DOWNLOAD_DIR"
    echo "Directory 'downloads' created at $HOME"
else
    echo "Directory 'downloads' already exists at $HOME"
fi

echo ""
# Prompt for the object file name
read -p "Enter the object file name to download from the bucket: " OBJECT_NAME

# Download the tar file from OCI Object Storage
oci os object get --bucket-name "$BUCKET_NAME" --name "$OBJECT_NAME" --file "$LOCAL_DOWNLOAD_PATH/$OBJECT_NAME"

echo "$BUCKET_NAME" 

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download tar file from bucket '$BUCKET_NAME'."
    exit 1
fi

echo "Tar file downloaded successfully to $LOCAL_DOWNLOAD_PATH."

# Extract the tar file
tar -xvf "$LOCAL_DOWNLOAD_PATH/$OBJECT_NAME" -C "$EXTRACT_PATH"

# Check if the extraction was successful
if [ $? -ne 0 ]; then
    echo "Failed to extract tar file."
    exit 1
fi

echo "Tar file extracted successfully to $EXTRACT_PATH."

# Restore each database from the latest extracted SQL files
for DATABASE_DIR in "$EXTRACT_PATH"/*; do
    if [ -d "$DATABASE_DIR" ]; then
        # Get the database name from the directory
        DATABASE_NAME=$(basename "$DATABASE_DIR")
        
        # Find the latest SQL file in the directory based on modification time or name pattern
        SQL_FILE=$(find "$DATABASE_DIR" -name "*.sql" -type f | sort -V | tail -n 1)
    
        if [ -f "$SQL_FILE" ]; then
            # Restore the database
            mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DATABASE_NAME" < "$SQL_FILE"
            
            if [ $? -ne 0 ]; then
                echo "Failed to restore database '$DATABASE_NAME' from '$SQL_FILE'."
            else
                echo "Database '$DATABASE_NAME' restored successfully from '$SQL_FILE'."
            fi
        else
            echo "No SQL file found in directory '$DATABASE_DIR'."
        fi
    fi
done

echo "Database restore process completed."
echo " "

}






# Function for delete-all-except-latest.sh
delete_all_except_latest() {

#!/bin/bash

# ============================================
# ATTENTION: This script will delete old backups
# in the specified Object Storage bucket, keeping
# ONLY the most recent backup.
# WARNING: Run with caution.
# ============================================

# User-configurable variables
NAMESPACE=$(oci os ns get --query 'data' --raw-output)
#BUCKET_NAME="Database-Backup"  # Replace with your actual bucket name

# Prompt for confirmation before proceeding
read -p "WARNING: This action will permanently delete old backups and keep only the latest. Are you sure you want to continue? (yes/no): " confirmation

if [[ "$confirmation" != "yes" ]]; then
    echo "Action aborted. No objects were deleted."
    exit 1
fi

# Find the latest backup object by modification date
LATEST_OBJECT=$(oci os object list -ns $NAMESPACE -bn $BUCKET_NAME --fields name,timeModified --query 'data | sort_by(@, &"time-modified") | reverse(@) | [0].name' --raw-output | tr -d '"')

echo "Latest backup is: $LATEST_OBJECT"

# Loop through and delete all objects except the latest one
for OBJECT in $(oci os object list -ns $NAMESPACE -bn $BUCKET_NAME --query "data[?name!='$LATEST_OBJECT'].name" --raw-output | tr -d '",' | sed 's/^\[//;s/\]$//')
do
    echo "Deleting $OBJECT..."
    oci os object delete -ns $NAMESPACE -bn $BUCKET_NAME --name "$OBJECT" --force
done

echo "Deletion complete. Only the latest backup remains."

}








while true; do
# Main script to choose which function to execute
echo " "
echo " "
echo "Please select the operation you want to perform:"
echo "  1. Create a TAR backup of MySQL databases within your VM (backup_in_tar)"
echo "  2. Upload the TAR backup to OCI Bucket (upload_to_bucket)"
echo "  3. Download and restore latest MySQL databases backup from Bucket (download_and_restore)"
echo "  4. Delete all backups in bucket except the latest one (delete_all_except_latest)"
echo " "
echo " "
read -p "Enter the number corresponding to your choice: " choice
echo " "
echo " "
case $choice in
    1) backup_in_tar ;;
    2) upload_to_bucket ;;
    3) download_and_restore ;;
    4) delete_all_except_latest ;;
    *) echo "Invalid choice. Exiting." ;;
esac
# Ask if the user wants to perform another operation
    read -p "Would you like to perform another operation? (yes/no): " again
    if [[ "$again" != "yes" ]]; then
        echo "Exiting script. Goodbye!"
        break
    fi
done