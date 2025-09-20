#!/bin/bash
# Variables
backupPath="/backup"
mongoDbName=""                  # Change this to your database name
mongoPort="27017"                     # Port where MongoDB is running
mongoHost="localhost"                 # MongoDB host (adjust if using a different host)

# Step 1: Stop MongoDB service (optional, to prevent conflicts)
echo "Stopping MongoDB service..."
sudo systemctl stop mongod

# Step 2: Remove existing data (optional, if you want to replace everything)
echo "Cleaning existing data..."
sudo rm -rf /var/lib/mongo/*

# Step 3: Restore from backup
echo "Restoring data from $backupPath..."
mongorestore --host=$mongoHost --port=$mongoPort --dir=$backupPath --drop

# The --drop option drops existing collections before import

# Step 4: Start MongoDB service
echo "Starting MongoDB service..."
sudo systemctl start mongod

echo "Restoration complete."