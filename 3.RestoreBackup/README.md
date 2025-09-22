# RestoreBackup
Scripts and procedures to restore MongoDB backups from S3 to EC2 instances. Includes guidance on selecting the correct backup files and restoring the database to a desired state.

## Steps to restore a database 👣
1. Stop the MongoDB service (optional, to prevent conflicts during restore):
```
sudo systemctl stop mongod
```

2. Create a directory for the backup:
```
mkdir -p backups/01032025200001
```

3. Download the backup from S3:
```
aws s3 cp s3://backup /backups/01032025200001 --recursive
```

4. Stop MongoDB before restoring (if not already stopped), to ensure a clean restore process:
```
sudo systemctl stop mongod
```

5. Create the target database if it does not exist:
MongoDB creates databases automatically when data is inserted, so typically, no manual creation is required. Just ensure that the restore process is pointed to the correct database.

6. Restore the database from the backup:
```
mongorestore --host=$MONGO_HOST --port=$MONGO_PORT --dir=/backups/01032025200001 --drop
```

7. The --drop option ensures that existing collections are dropped before restoring.
8. Verify the restored databases and data
9. Restart the MongoDB service:
```
sudo systemctl start mongod
```


