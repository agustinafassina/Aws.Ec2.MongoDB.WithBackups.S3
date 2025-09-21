# Aws.Ec2.MongoDB.Backups
This repository contains several scripts to install MongoDB on EC2 instances, generate backups, and restore them, storing the backups securely in an S3 bucket. The scripts enable automated backup and restore processes, ensuring data security and facilitating recovery when needed. The process covers the entire lifecycle—from installing MongoDB on EC2, creating backups, to restoring them as required.

### Folder structure
1. InstallMongoDB.Ec2: Scripts and steps to install MongoDB on EC2 instances.
2.GenerateBackup: Scripts and information to generate and store backups in S3.
3. RestoreBackup: Scripts and procedures to restore backups from S3 to EC2.