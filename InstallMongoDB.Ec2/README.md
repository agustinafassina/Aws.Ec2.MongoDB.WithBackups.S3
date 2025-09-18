# InstallMongoDB.Ec2
Scripts and step-by-step instructions to install MongoDB on EC2 instances. These scripts facilitate quick and reliable deployment of MongoDB servers, ensuring consistent setup across environments.

<img src="aws.png" alt="Aws" width="400" height="450">

### Requirenment
- You need to have an aws account.

### Steps
- From Aws / EC2 / With the region selected.
- Create new instance -> Launch instances.
- Create new instance
- Select Quick Start -> Ubuntu and Ubuntu Server 24.04

<img src="ubuntu-detail.png" alt="Aws" width="400" height="450">
- Ubuntu 24.04–8gb
- Connect to the instance

#### Then run the following commands
- Import the public key used by the package management system

```
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor
```

- Add sources
```
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
```

- Reload local package database
```
sudo apt update
```

- Install the MongoDB
```
sudo apt install -y mongodb-org
```

- Mongodb version and run
```
mongod –version
sudo systemctl start mongod
```

- If you didn’t get any errors and Mongo is already running, we can enable binIdP so we can connect by uploading our IP to the security group.
```
sudo nano /etc/mongod.conf
```

- Replate the binIdP value 127.0.0.1 to 0.0.0.0
<img src="ubuntu-detail.png" alt="Aws" width="400" height="450">

```
sudo systemctl restart mongod
```

- Add your ip in the security group that has the associated instance.
- If you already uploaded the IP, you can test the connection to the instance.

#### How to test if the instance and mongo are working correctly?
- Download https://robomongo.org/ to connect to the database.
- With your Public IPv4 DNS