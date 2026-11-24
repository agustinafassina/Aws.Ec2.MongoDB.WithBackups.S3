# RestoreBackup
Scripts and procedures to restore MongoDB backups from S3 to EC2 instances. Includes guidance on selecting the correct backup files and restoring the database to a desired state.

> ⚠️ `mongorestore` connects to a **running** MongoDB server. Do **not** stop `mongod` before restoring.

## Steps to restore a database 👣
1. List the available backups in S3 (each one is a timestamp folder created by `generate-backup.sh`):
```
aws s3 ls s3://<bucket>/<prefix>/
```

2. Create a local directory for the backup:
```
mkdir -p ~/backups/20250301_050001
```

3. Download the backup from S3:
```
aws s3 cp s3://<bucket>/<prefix>/20250301_050001 ~/backups/20250301_050001 --recursive
```

4. Make sure MongoDB is running:
```
sudo systemctl start mongod
```

5. Create the target database if it does not exist:
MongoDB creates databases automatically when data is inserted, so typically, no manual creation is required. Just ensure that the restore process is pointed to the correct database.

6. Restore the database from the backup (using the script or manually):

   **Using the script (recommended):**
   ```bash
   export BACKUP_PATH=~/backups/20250301_050001
   export MONGO_HOST=localhost
   export MONGO_PORT=27017
   # If backup was created with --gzip:
   export RESTORE_GZIP=true
   # Optional: restore only one database:
   export MONGO_DB_NAME=my_database
   ./restore-backup.sh
   ```

   **Manual:**
   ```
   mongorestore --host=$MONGO_HOST --port=$MONGO_PORT --dir=$HOME/backups/20250301_050001 --drop
   ```
   For gzip backups add: `--gzip`. To restore only one database add: `--nsInclude="my_database.*"`

7. The `--drop` option ensures that existing collections are dropped before restoring.
8. Verify the restored databases and data.
