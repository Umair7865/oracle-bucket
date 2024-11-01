#!/bin/bash

# Variables
# NAMESPACE=$(oci os ns get --query 'data' --raw-output)

BUCKET_NAME="<enter name of bucket>"                                                    # Replace with your bucket name
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
