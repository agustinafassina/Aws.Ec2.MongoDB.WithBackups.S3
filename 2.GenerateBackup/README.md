# GenerateBackup
Scripts and instructions to create automated daily backups of MongoDB. These scripts can be scheduled via cron to run daily, generating backups that are securely uploaded and stored in an S3 bucket. The folder includes detailed guidance on setting up the cron job and managing backup files.

## Script options
- **Normal:** `./generate-backup.sh`
- **Compressed (recommended for large DBs):** `./generate-backup.sh --gzip` — saves space and transfer time; use `RESTORE_GZIP=true` when restoring.

Logs are written to `/var/log/mongodb-backup.log`. A lock file prevents overlapping runs if cron overlaps.

## Steps to generate backups 👣
1. Add AWS CLI to the instance
```
sudo snap install aws-cli --classic
```
2. Version review
```
aws --version
```
3. If the instance does not have a role attached, you must add an access key with permissions to push to S3.
```
aws configure
```
4. Edit the script: set `S3_BUCKET`, `S3_PREFIX`, and optionally `BACKUP_BASE` / `LOG_FILE`.
```
vim generate-backup.sh
```
5. Ensure log directory exists (for cron): `sudo touch /var/log/mongodb-backup.log && sudo chown ubuntu:ubuntu /var/log/mongodb-backup.log`
6. Add the script to the instance and make it executable: `chmod +x generate-backup.sh`
7. Have the S3 bucket and prefix ready.
8. For automation, add a cron job (examples):
   - Every day at 5 AM: `0 5 * * * /home/ubuntu/generate-backup.sh --gzip >> /var/log/mongodb-backup.log 2>&1`
   - Every Friday at 5 AM: `0 5 * * 5 /home/ubuntu/generate-backup.sh --gzip >> /var/log/mongodb-backup.log 2>&1`


