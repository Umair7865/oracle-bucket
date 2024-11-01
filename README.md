# Backup and Restore Automation Scripts

Automate your database backup, upload, download, restoration, and cleanup processes with these shell scripts. Designed for ease of use and efficiency, these scripts help manage your backups stored in Oracle Cloud Infrastructure (OCI) Object Storage.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Scripts](#scripts)
  - [backup-in-tar.sh](#backup-in-tarsh)
  - [upload-to-bucket.sh](#upload-to-bucketsh)
  - [download-and-restore.sh](#download-and-restoresh)
  - [delete-all-object-except-latest.sh](#delete-all-object-except-latestsh)
  - [backup-and-restore-automation.sh](#backup-and-restore-automationsh)
- [Usage](#usage)
- [Contributing](#contributing)

## Features

- **Backup Automation**: Create tar archives of your database backups on the instance.
- **Upload to OCI Bucket**: Upload tar files to OCI Object Storage for secure and centralized storage.
- **Download & Restore**: Download tar files from OCI Object Storage, extract them, and restore databases.
- **Cleanup**: Automatically delete older backups, retaining only the latest one.
- **Unified Script**: One interactive script to perform all operations.

## Prerequisites

Before using these scripts, ensure you have the following:

- **Operating System**: Unix-based (Linux, macOS)
- **OCI CLI**: Installed and configured. [OCI CLI Installation Guide](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__linux_and_unix)
- **MySQL**: Installed and configured.
- **Basic Shell Knowledge**: Familiarity with running shell scripts.

## Installation

1. **Clone the Repository**

   ```bash
   https://github.com/Umair-Gillani/Backup-and-Restore-Automation-Scripts.git
   cd Backup-and-Restore-Automation-Scripts
   ```

2. **Make Scripts Executable**

   ```bash
   chmod +x backup-and-restore-automation.sh
   chmod +x individual_scripts/*
   ```

## Scripts

### `backup-in-tar.sh`

Automates the backup process by archiving database dumps into tar files.

#### Configuration

1. **Provide Source Directory Path**

   Ensure you provide the complete path of the parent directory containing all database backups. Each database should have its own folder named exactly after the database.

   **Example Directory Structure:**

   ```
   /path/to/backups/    # provide name 'backups' into script
   ├── database1/
   │   └── dump.sql
   └── database2/
       └── dump.sql
   ```

2. **Run the Script**

   ```bash
   ./backup-in-tar.sh 
   ```

---

### `upload-to-bucket.sh`

Uploads the created tar files to your specified OCI Object Storage bucket, ensuring your backups are securely stored in the cloud.

#### Configuration

Before running the script, set the required variables inside the script:

```bash
# Variables
BUCKET_NAME="<Bucket-Name-Here>"    # Replace with your OCI bucket name within script
```

#### Script Functionality

1. **Verify Directory**: Ensures the local tar directory exists; exits if not found.
2. **Upload Files**: Uploads the tar file to the OCI bucket using OCI CLI, confirming the upload.
3. **Completion Message**: Notifies once the file is successfully uploaded.

#### Run the Script

```bash
./upload-to-bucket.sh
```

---

### `download-and-restore.sh`

Downloads a tar file from OCI Object Storage, extracts it, and restores the databases.

#### Configuration

Before running the script, set the required variables inside the script:

```bash
# Variables
BUCKET_NAME="<Bucket-Name-Here>"       # Replace with your bucket name
MYSQL_USER="root"                      # Replace with your MySQL username
MYSQL_PASSWORD="root123"               # Replace with your MySQL password
```

#### Script Functionality

1. **Check/Create Download Directory**

   The script first checks if the download directory exists in your home directory (`$HOME`). If it doesn't exist, the script will create it. This ensures there's a designated place to store the downloaded tar files.

2. **User Input for Object Name**

   If the download directory already exists, the script will prompt you to enter the name of the tar file you wish to download from your OCI bucket. This allows you to specify which backup you want to restore.

3. **Download and Extract**

   The script downloads the specified tar file from the OCI bucket to the local download directory. Once downloaded, it extracts the contents of the tar file to the designated extraction path.

   **Output Message:**

   After successful extraction, you will see a message like:

   ```
   Tar file extracted successfully to /home/your-username/downloads.
   ```

   This confirms that the tar file has been successfully unpacked and the SQL files are ready for restoration.

4. **Restore Databases**

   After extraction, the script automatically restores each database using the SQL files extracted from the tar archive.

   - **Identify SQL Files**: The script finds the latest SQL file within each database folder and restores that latest dump to ensure the most up-to-date data is used.

   - **Restore Process**: The script imports the SQL file into the corresponding database, and displays success or failure messages accordingly.

   - **Completion Message**: Once all databases have been processed, the script will display:

     ```
     Database restore process completed.
     ```

#### Run the Script

```bash
./download-and-restore.sh
```

---

### `delete-all-object-except-latest.sh`

Cleans up the OCI bucket by deleting all objects except the latest one.

#### Configuration

Set the required variables inside the script:

```bash
BUCKET_NAME="<Bucket-Name-HERE>"    # Replace with your actual bucket name
```

#### Script Functionality

1. **List Objects in Bucket**

   The script retrieves a list of all objects stored in the specified OCI bucket.

2. **Identify Latest Object**

   It determines the most recent object based on the last modified timestamp, ensuring the latest backup is retained.

3. **Delete Older Objects**

   All objects except the latest one are deleted from the bucket to manage storage space effectively.

#### Example Output

```
WARNING: This action will permanently delete old backups and keep only the latest. Are you sure you want to continue? (yes/no): yes
Latest backup is: latest_database_backup_2024-10-30__13_hour-44_min.tar
Deleting latest_database_backup_2024-10-30__13_hour-41_min.tar...
Deleting latest_database_backup_2024-10-30__13_hour-43_min.tar...
Deletion complete. Only the latest backup remains.
```

#### Run the Script

```bash
./delete-all-object-except-latest.sh
```

---

### `backup-and-restore-automation.sh`

Provides a single interface to perform all backup and restore operations, including archiving, uploading, downloading, restoring, and deleting backups.

#### Functionality

This script combines all individual backup, upload, download, restore, and cleanup operations into one unified script. The user is prompted to select from these options, and the appropriate function is executed based on their choice.

1. **Backup Databases**: Archives MySQL database dumps into a compressed `.tar.gz` file.
2. **Upload to OCI Bucket**: Uploads the tar file to the specified OCI Object Storage bucket.
3. **Download and Restore Databases**: Downloads the latest tar file from the OCI bucket, extracts it, and restores the databases.
4. **Cleanup Old Backups**: Deletes all but the most recent backup file from the OCI bucket.

#### Usage

Run the script and select an option from the menu:

```bash
./backup-and-restore-automation.sh
```

This interactive script guides you through each step, making it easier to perform individual operations as needed.

---

## Usage

1. **Backup Databases**

   Use `backup-in-tar.sh` to archive your database dumps.

   ```bash
   ./backup-in-tar.sh 
   ```

2. **Upload to OCI Bucket**

   Use `upload-to-bucket.sh` to upload the tar files to your OCI Object Storage bucket.

   ```bash
   ./upload-to-bucket.sh
   ```

3. **Download and Restore Databases**

   Use `download-and-restore.sh` to download the latest backup and restore the databases.

   ```bash
   ./download-and-restore.sh
   ```

4. **Cleanup Old Backups**

   Use `delete-all-object-except-latest.sh` to remove outdated backups from the OCI bucket.

   ```bash
   ./delete-all-object-except-latest.sh
   ```

5. **Run All Operations via Menu**

   Use `backup-and-restore-automation.sh` to select from all available operations.

   ```bash
   ./backup-and-restore-automation.sh
   ```

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

1. **Fork the Repository**
2. **Create a Feature Branch**

   ```bash
   git checkout -b feature/YourFeature
   ```

3. **Commit Your

 Changes**

   ```bash
   git commit -m "Add your message"
   ```

4. **Push to the Branch**

   ```bash
   git push origin feature/YourFeature
   ```

5. **Open a Pull Request**

---
