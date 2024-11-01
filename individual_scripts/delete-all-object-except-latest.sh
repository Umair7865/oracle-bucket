#!/bin/bash

# ============================================
# ATTENTION: This script will delete old backups
# in the specified Object Storage bucket, keeping
# ONLY the most recent backup.
# WARNING: Run with caution.
# ============================================

# User-configurable variables
NAMESPACE="axor0ymlfntq"  # Replace with your actual namespace
BUCKET_NAME="Database-Backup"  # Replace with your actual bucket name

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
