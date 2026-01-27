# Docker Compose Patterns

## Basic Structure

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:80"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
    networks:
      - frontend
      - backend

  db:
    image: postgres:15
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: myapp
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    networks:
      - backend

volumes:
  db_data:

networks:
  frontend:
  backend:

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

## Health Checks

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Resource Limits

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

## Multiple Compose Files

```bash
# Base + overrides
docker compose -f docker-compose.yml -f docker-compose.prod.yml up

# Or use COMPOSE_FILE
export COMPOSE_FILE=docker-compose.yml:docker-compose.prod.yml
docker compose up
```

## Environment Variables

```yaml
# .env file
services:
  app:
    image: myapp:${VERSION:-latest}
    environment:
      - DATABASE_URL=${DATABASE_URL}
    env_file:
      - .env
      - .env.local
```

## Service Profiles

```yaml
services:
  app:
    profiles: []  # Always starts
    
  debug:
    profiles: [debug]
    # Only starts with --profile debug
```

## Extension Fields

```yaml
x-common: &common
  restart: unless-stopped
  logging:
    driver: json-file
    options:
      max-size: "10m"

services:
  app:
    <<: *common
    image: myapp
```
