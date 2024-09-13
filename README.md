# MySQL Database Backup and Restoration Automation

This project automates the process of backing up MySQL databases, uploading the backups to Oracle Cloud Object Storage, and restoring them when needed. Below is an overview of how each script works and the setup required.

## Setup Instructions

To securely upload backups to a private bucket in Oracle Cloud, you need to configure the Oracle Cloud Infrastructure CLI and set up the necessary credentials.

### 1. Configure OCI CLI with API Keys

- **Create API Keys**: Generate API keys in your Oracle Cloud account:
  - Navigate to your user settings in the Oracle Cloud Console.
  - Under "Resources," click on "API Keys."
  - Click "Add API Key" and follow the prompts to generate a key pair.
  - Download and securely save the private key; you'll need it for authentication.

- **Install OCI CLI**: If you haven't already, install the OCI CLI on your local machine following [Oracle's installation guide](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm).

- **Configure OCI CLI**: Run the following command and provide the required information:

  ```bash
  oci setup config
  ```

  - When prompted, provide your **User OCID**, **Tenancy OCID**, **Region**, and the path to your **private key**.
  - The configuration will be saved in the `~/.oci/config` file.

### 2. Create a Private Bucket on Oracle Cloud

- **Create Bucket**:
  - Log in to the Oracle Cloud Console.
  - Navigate to **Object Storage** under **Storage**.
  - Click **Create Bucket**.
  - Enter a name for your bucket (e.g., `Database-Backup`).
  - Set the bucket type to **Private** to restrict public access.
  - Click **Create**.

- **Note the Bucket Name**: Copy the exact name of the bucket; you'll need this for the upload script.

### 3. Update the Upload Script

- **Bucket Name**: In your upload script, replace the `BUCKET_NAME` variable with the name of your private bucket.
  
  ```bash
  BUCKET_NAME="Your-Bucket-Name"
  ```

- **File Path**: Ensure the `FILE_PATH` variable points to the location of your backup archive.
  
  ```bash
  FILE_PATH="/path/to/your/backup_mysql.tar.gz"
  ```

- **Test the Upload**: Run the upload script manually to confirm that backups are being uploaded successfully.

## Backup and Upload Process

1. **Backup Script**: Creates a compressed archive (`.tar.gz` file) of MySQL database backups from a specified folder and saves it to a destination folder.

2. **Upload Script**: Uses the OCI CLI and your `~/.oci/config` file to authenticate and upload the created archive to your private Oracle Cloud Object Storage bucket. The script assigns a unique name to the file, including the date and time, ensuring each backup is distinguishable.

## Restoration Process

1. **Download and Extract**: Downloads a specified backup file from the Oracle Cloud bucket using the OCI CLI and extracts it to a local directory.

2. **Restore Databases**: Scans the extracted folders to find the latest SQL files for each database and restores them using the MySQL command-line tool. The script logs success or failure messages for each database restoration.

---

This overview provides the necessary information to set up and understand the automation process for backing up and restoring MySQL databases using Oracle Cloud Object Storage.

---

Image of Generating API keys for `~/.oci/config` file
![image](https://github.com/user-attachments/assets/0e11183f-1109-4e06-aa56-8e6175a63ecc)
