---
title: "Running MongoDB ReplicaSet on localhost"
date: 2019-01-11T08:58:04+0000
---

Setup Cluster
=============

Create Instances
----------------

Create directories:

```
mkdir -p /tmp/mongodb/rs-{0,1,2}
```
In shell, run:
```shell
mongod --dbpath /tmp/mongodb/rs-0 --replSet rs --port 27021 --bind_ip localhost --smallfiles --oplogSize 128
mongod --dbpath /tmp/mongodb/rs-1 --replSet rs --port 27022 --bind_ip localhost --smallfiles --oplogSize 128
mongod --dbpath /tmp/mongodb/rs-2 --replSet rs --port 27023 --bind_ip localhost --smallfiles --oplogSize 128
```

Initiate ReplicaSet
-------------------

Run client to initiate ReplicaSet:

```shell
mongo --port 27021
```
Create ReplicaSet configuration:
```javascript
rs.initiate({
    _id : 'rs',
    members: [
      { _id : 0, host : "localhost:27021" },
      { _id : 1, host : "localhost:27022" },
      { _id : 2, host : "localhost:27023" }
    ]
})
```
Review with:
```
rs.conf()
```
# Configuring Authorization

Establishing Auth
-----------------

Connecting to ReplicaSet

```shell
mongo "mongodb://localhost:27021,localhost:27022,localhost:27023/?replicaSet=rs"
```
Establishing auth:

```
use admin;
```
Then, create a user:
```javascript
db.createUser({ user: "ft-user", pwd: "3aPFfSIgebQcW1nhliXi", roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]})
```
Exit:
```
exit
```
## Create Keyfile

Create a keyfile for internal authentication:

```shell
openssl rand -base64 360 > /tmp/mongodb/keyfile
chmod 600 /tmp/mongodb/keyfile
```
Keyfile must not be *world*-readable.  Otherwise, `mongod` will complain:
```
2018-09-02T12:29:58.997+0200 I ACCESS   [main] permissions on /tmp/mongodb/keyfile are too open
```
# Running Cluster with Authentication

Rerun all replica members. Repeat this for all three members:

```shell
mongod --replSet rs --port 27021 --bind_ip localhost --dbpath /tmp/mongodb/rs-0 --smallfiles --oplogSize 128 --auth --keyFile /tmp/mongodb/keyfile
mongod --replSet rs --port 27022 --bind_ip localhost --dbpath /tmp/mongodb/rs-1 --smallfiles --oplogSize 128 --auth --keyFile /tmp/mongodb/keyfile
mongod --replSet rs --port 27023 --bind_ip localhost --dbpath /tmp/mongodb/rs-2 --smallfiles --oplogSize 128 --auth --keyFile /tmp/mongodb/keyfile
```
Connect to Cluster with Proper Credentials
------------------------------------------

Now, re-authenticate with proper credentials:

```shell
mongo "mongodb://localhost:27021,localhost:27022,localhost:27023/?replicaSet=rs" --username 'ft-user' --password 3aPFfSIgebQcW1nhliXi --authenticationDatabase admin
```
The following command should work fine now:

```
show dbs
```

