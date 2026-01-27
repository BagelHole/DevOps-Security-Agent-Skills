# Docker Command Reference

## Container Lifecycle

```bash
# Run container
docker run -d --name myapp -p 8080:80 nginx
docker run -it --rm ubuntu bash

# Start/Stop
docker start myapp
docker stop myapp
docker restart myapp

# Remove
docker rm myapp
docker rm -f myapp  # Force

# Logs
docker logs myapp
docker logs -f myapp        # Follow
docker logs --tail 100 myapp
```

## Images

```bash
# List/Pull/Build
docker images
docker pull nginx:latest
docker build -t myapp:1.0 .
docker build -t myapp:1.0 -f Dockerfile.prod .

# Tag/Push
docker tag myapp:1.0 registry.example.com/myapp:1.0
docker push registry.example.com/myapp:1.0

# Remove
docker rmi myapp:1.0
docker image prune -a  # Remove unused
```

## Inspection

```bash
# Container info
docker ps
docker ps -a
docker inspect myapp
docker stats
docker top myapp

# Exec into container
docker exec -it myapp bash
docker exec myapp ls -la /app
```

## Networks

```bash
# List/Create
docker network ls
docker network create mynet

# Connect container
docker network connect mynet myapp
docker run --network mynet nginx
```

## Volumes

```bash
# List/Create
docker volume ls
docker volume create mydata

# Mount
docker run -v mydata:/data nginx
docker run -v $(pwd):/app nginx
docker run --mount type=bind,source=$(pwd),target=/app nginx
```

## Cleanup

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove everything unused
docker system prune -a --volumes

# Disk usage
docker system df
```

## Multi-stage Build

```dockerfile
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```
