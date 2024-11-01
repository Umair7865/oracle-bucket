#!/bin/bash

# Variables
NAMESPACE=$(oci os ns get --query 'data' --raw-output)
BUCKET_NAME="<Bucket-Name-Here>"  # Replace with your bucket name
LOCAL_DOWNLOAD_PATH="$HOME/downloads"  # Directory where the tar file will be downloaded
EXTRACT_PATH="$HOME/downloads"  # Directory where the tar file will be extracted
MYSQL_USER="root"  # Replace with your MySQL username
MYSQL_PASSWORD="root123"  # Replace with your MySQL password

# making downloads directory if not exist 
DOWNLOAD_DIR="$HOME/download"

# Check if the directory exists
if [ ! -d "$DOWNLOAD_DIR" ]; then
    # If not, create the directory
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
