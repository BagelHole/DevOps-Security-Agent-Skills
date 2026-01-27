---
name: mongodb
description: Administer MongoDB databases. Configure replica sets, sharding, and backups. Use when managing MongoDB deployments.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# MongoDB

Administer MongoDB NoSQL databases.

## Installation & Setup

```bash
# Install
apt install mongodb-org

# Start service
systemctl start mongod

# Connect
mongosh

# Create user
use admin
db.createUser({
  user: "admin",
  pwd: "secret",
  roles: ["root"]
})
```

## Basic Operations

```javascript
// Create database and collection
use mydb
db.users.insertOne({ name: "John", email: "john@example.com" })

// Query
db.users.find({ name: "John" })
db.users.find().sort({ name: 1 }).limit(10)

// Index
db.users.createIndex({ email: 1 }, { unique: true })
```

## Replica Set

```javascript
// Initialize replica set
rs.initiate({
  _id: "myReplicaSet",
  members: [
    { _id: 0, host: "mongo1:27017" },
    { _id: 1, host: "mongo2:27017" },
    { _id: 2, host: "mongo3:27017" }
  ]
})
```

## Backup

```bash
# Backup
mongodump --out /backup/

# Restore
mongorestore /backup/
```

## Best Practices

- Use replica sets in production
- Implement proper indexing
- Enable authentication
- Regular backups with mongodump
