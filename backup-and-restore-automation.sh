#!/bin/bash

# Function for backup-in-tar.sh
backup_in_tar() {
    ARCHIVE_NAME="backup_mysql.tar.gz"
    DESTINATION_FOLDER="$HOME/backup-in-tar"
    SOURCE_FOLDER="$HOME/MySQL"

    # Create destination folder if it doesn't exist
    if [ ! -d "$DESTINATION_FOLDER" ]; then
        mkdir -p "$DESTINATION_FOLDER"
        echo "Directory 'backup-in-tar' created at $HOME"
    else
        echo "Directory 'backup-in-tar' already exists at $HOME"
    fi

    # Archive the folder
    tar -czf $DESTINATION_FOLDER/$ARCHIVE_NAME -C $SOURCE_FOLDER .

    echo " "
    echo "Congratulations!!! TAR file of your database has been created under directory $HOME/backup-in-tar"
    echo " "
}

# Function for upload-to-bucket.sh
upload_to_bucket() {
    BUCKET_NAME="<enter name of bucket>"
    OBJECT_NAME="latest_database_backup_$(date +%F__%H_hour-%M_min).tar"
    FILE_PATH="$HOME/backup-in-tar/backup_mysql.tar.gz"

    # Upload the file
    oci os object put --bucket-name $BUCKET_NAME --name $OBJECT_NAME --file $FILE_PATH

    # Check if the upload was successful
    if [ $? -eq 0 ]; then
        echo "File '$FILE_PATH' uploaded to bucket '$BUCKET_NAME' as '$OBJECT_NAME'."
    else
        echo "Failed to upload file '$FILE_PATH'."
    fi
}

# Function for download-and-restore.sh
download_and_restore() {
    NAMESPACE=$(oci os ns get --query 'data' --raw-output)
    BUCKET_NAME="<Bucket-Name-Here>"
    LOCAL_DOWNLOAD_PATH="$HOME/downloads"
    EXTRACT_PATH="$HOME/downloads"
    MYSQL_USER="root"
    MYSQL_PASSWORD="root123"

    # Create downloads directory if it doesn't exist
    DOWNLOAD_DIR="$HOME/download"
    if [ ! -d "$DOWNLOAD_DIR" ]; then
        mkdir "$DOWNLOAD_DIR"
        echo "Directory 'download' created at $HOME"
    else
        echo "Directory 'download' already exists at $HOME"
    fi

    # Prompt for the object file name
    read -p "Enter the object file name to download from the bucket: " OBJECT_NAME

    # Download the tar file from OCI Object Storage
    oci os object get --bucket-name "$BUCKET_NAME" --name "$OBJECT_NAME" --file "$LOCAL_DOWNLOAD_PATH/$OBJECT_NAME"

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
            DATABASE_NAME=$(basename "$DATABASE_DIR")
            SQL_FILE=$(find "$DATABASE_DIR" -name "*.sql" -type f | sort -V | tail -n 1)
            if [ -f "$SQL_FILE" ]; then
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
}

# Function for delete-all-except-latest.sh
delete_all_except_latest() {
    NAMESPACE=$(oci os ns get --query 'data' --raw-output)
    BUCKET_NAME="<Bucket-Name-Here>"

    # Get the name of the latest object
    LATEST_OBJECT=$(oci os object list -ns $NAMESPACE -bn $BUCKET_NAME --query 'data[-1].name' --raw-output)

    # Loop through and delete all objects except the latest one
    for OBJECT in $(oci os object list -ns $NAMESPACE -bn $BUCKET_NAME --query "data[?name!='$LATEST_OBJECT'].name" --raw-output | tr -d '",' | sed 's/^\[//;s/\]$//'); do
        echo "Deleting $OBJECT..."
        oci os object delete -ns $NAMESPACE -bn $BUCKET_NAME --name "$OBJECT" --force
    done

    echo "Deletion complete. Only the latest backup remains."
}

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
