---
name: redis
description: Configure Redis for caching and data storage. Set up clustering, persistence, and Sentinel. Use when implementing Redis caching or queues.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Redis

Configure Redis for caching and data storage.

## Installation & Setup

```bash
# Install
apt install redis-server

# Configuration
# /etc/redis/redis.conf
bind 0.0.0.0
protected-mode yes
requirepass yourpassword
maxmemory 256mb
maxmemory-policy allkeys-lru
```

## Basic Operations

```bash
redis-cli -a yourpassword

# String operations
SET key "value"
GET key
SETEX key 3600 "value"  # With TTL

# Hash
HSET user:1 name "John" email "john@example.com"
HGETALL user:1

# List
LPUSH queue "task1"
RPOP queue
```

## Persistence

```bash
# RDB (snapshot)
save 900 1
save 300 10

# AOF (append-only file)
appendonly yes
appendfsync everysec
```

## Sentinel (HA)

```bash
# sentinel.conf
sentinel monitor mymaster 10.0.0.1 6379 2
sentinel down-after-milliseconds mymaster 30000
sentinel failover-timeout mymaster 180000
```

## Best Practices

- Set maxmemory and eviction policy
- Use persistence for critical data
- Implement Sentinel for HA
- Monitor memory usage
