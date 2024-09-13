# MySQL Database Backup and Restoration Automation
This project automates the process of backing up MySQL databases, uploading the backups to Oracle Cloud Object Storage, and restoring them when needed. Below is an overview of how each script works and additional setup steps.

## Backup and Upload Process
1. **Backup Script**: Creates a compressed archive (`.tar.gz` file) of MySQL database backups from a specified folder and saves it to a destination folder.

2. **Upload Script**: Uploads the created archive to an Oracle Cloud Object Storage bucket using the `~/.oci/config` file for authentication. The script assigns a unique name to the file, including the date and time, ensuring each backup is distinguishable.
---

## Setting Up Oracle Cloud for Uploads
1. **Create API Keys**:
   - Generate API keys in Oracle Cloud, and save the private key securely.
   - Use these keys in your `~/.oci/config` file to authenticate and upload data to the bucket privately.

2. **Create a Private Bucket**:
   - Set up a private bucket on Oracle Cloud to securely store your database backups.
   - Ensure the bucket permissions are set to private to restrict access.

3. **Configure Bucket Name**:
   - Copy the bucket name and update the upload script with the correct bucket name to ensure backups are uploaded to the correct location.
---

## Restoration Process
1. **Download and Extract**: Downloads a specified backup file from the Oracle Cloud bucket and extracts it to a local directory.

2. **Restore Databases**: Restores each database using the SQL files from the extracted backup. The script checks for the latest SQL file in each folder and uses it to restore the corresponding database.

---

Image of Generating API keys for `~/.oci/config` file
![image](https://github.com/user-attachments/assets/0e11183f-1109-4e06-aa56-8e6175a63ecc)
