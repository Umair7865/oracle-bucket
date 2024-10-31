# Backup and Restore Automation Scripts

Automate your database backup, upload, download, restoration, and cleanup processes with these shell scripts. Designed for ease of use and efficiency, these scripts help manage your backups stored in Oracle Cloud Infrastructure (OCI) Object Storage.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Scripts](#scripts)
  - [backup-in-tar.sh](#backup-in-tarsh)
  - [upload_to_bucket.sh](#upload_to_bucketsh)
  - [download_and_restore.sh](#download_and_restoresh)
  - [delete-all-object-except-latest.sh](#delete-all-object-except-latestsh)
- [Usage](#usage)
- [Contributing](#contributing)

## Features

- **Backup Automation**: Create tar archives of your database backups into instance.
- **Upload to OCI Bucket**: Upload tar files to OCI Object Storage for secure and centralized storage.
- **Download & Restore**: Download tar files from OCI Object Storage, extract them, and restore databases.
- **Cleanup**: Automatically delete older backups, retaining only the latest one.

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
   chmod +x backup-in-tar.sh upload_to_bucket.sh download_and_restore.sh delete-all-object-except-latest.sh
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

### `upload_to_bucket.sh`

Uploads the created tar files to your specified OCI Object Storage bucket, ensuring your backups are securely stored in the cloud.

#### Configuration

Before running the script, set the required variables inside the script:

```bash
# Variables
BUCKET_NAME="<Bucket-Name-Here>"    # Replace with your OCI bucket name within script
```

#### Script Functionality

1. **Verify Directory**: Ensures the local tar directory exists; exits if not found.
2. **List Tar Files**: Identifies all `.tar` files in the directory.
3. **Upload Files**: Uploads each tar file to the OCI bucket using OCI CLI, confirming each upload.
4. **Completion Message**: Notifies once all files are successfully uploaded.



#### Run the Script

```bash
./upload_to_bucket.sh
```

---


### `download_and_restore.sh`

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

   After extraction, the script automatically restores each database using the SQL files extracted from the tar archive. Here's how it works:

   - **Iterate Through Directories**: The script goes through each folder in the extraction path. Each folder should represent a separate database.

   - **Identify SQL Files**: Inside each database folder, the script looks for a file named `dump.sql`. This file contains the SQL commands needed to restore the database.

   - **Check for Latest Dump**: Additionally, the script identifies the most recent `dump.sql` file within each database folder and restores that latest dump to ensure the most up-to-date data is used.

   - **Restore Process**: Using the MySQL command-line tool, the script imports the `dump.sql` file into the corresponding database. If the restoration is successful, you will see a message like:

     ```
     Restored database1 successfully.
     ```

     If the `dump.sql` file is missing, it will notify you:

     ```
     SQL file not found for database1.
     ```

   - **Completion Message**: Once all databases have been processed, the script will display:

     ```
     Database restore process completed.
     ```

   This comprehensive process ensures that all your databases are accurately restored from the latest backups.

#### Run the Script

```bash
./download_and_restore.sh
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

   The script retrieves a list of all objects stored in the specified OCI bucket. This allows the script to know which backups are available.

2. **Identify Latest Object**

   It determines which object (tar file) is the most recent based on the last modified timestamp. This ensures that the latest backup is retained.

3. **Delete Older Objects**

   All objects except the latest one are deleted from the bucket. This helps in managing storage space by removing outdated backups while keeping the most recent one for recovery purposes.

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

## Usage

1. **Backup Databases**

   Use `backup-in-tar.sh` to archive your database dumps.

   ```bash
   ./backup-in-tar.sh 
   ```

2. **Upload to OCI Bucket**

   Use `upload_to_bucket.sh` to upload the tar files to your OCI Object Storage bucket.

   ```bash
   ./upload_to_bucket.sh
   ```

3. **Download and Restore Databases**

   Use `download_and_restore.sh` to download the latest backup and restore the databases.

   ```bash
   ./download_and_restore.sh
   ```

4. **Cleanup Old Backups**

   Use `delete-all-object-except-latest.sh` to remove outdated backups from the OCI bucket.

   ```bash
   ./delete-all-object-except-latest.sh
   ```

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

1. **Fork the Repository**
2. **Create a Feature Branch**

   ```bash
   git checkout -b feature/YourFeature
   ```

3. **Commit Your Changes**

   ```bash
   git commit -m "Add your message"
   ```

4. **Push to the Branch**

   ```bash
   git push origin feature/YourFeature
   ```

5. **Open a Pull Request**

---
