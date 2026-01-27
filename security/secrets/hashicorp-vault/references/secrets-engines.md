# Vault Secrets Engines Guide

## KV Secrets Engine (v2)

### Enable and Configure
```bash
# Enable KV v2
vault secrets enable -path=secret kv-v2

# Write secret
vault kv put secret/myapp/config \
    db_host="postgres.example.com" \
    db_user="myapp" \
    db_password="secret123"

# Read secret
vault kv get secret/myapp/config
vault kv get -field=db_password secret/myapp/config

# List secrets
vault kv list secret/myapp/

# Delete secret
vault kv delete secret/myapp/config

# Versioning
vault kv get -version=1 secret/myapp/config
vault kv rollback -version=1 secret/myapp/config
```

## Database Secrets Engine

### Setup Dynamic Credentials
```bash
# Enable database engine
vault secrets enable database

# Configure PostgreSQL
vault write database/config/myapp-db \
    plugin_name=postgresql-database-plugin \
    allowed_roles="myapp-role" \
    connection_url="postgresql://{{username}}:{{password}}@postgres:5432/myapp?sslmode=disable" \
    username="vault_admin" \
    password="admin_password"

# Create role
vault write database/roles/myapp-role \
    db_name=myapp-db \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

# Generate credentials
vault read database/creds/myapp-role
```

## AWS Secrets Engine

### Setup Dynamic AWS Credentials
```bash
# Enable AWS engine
vault secrets enable aws

# Configure root credentials
vault write aws/config/root \
    access_key=AKIAXXXXXXXX \
    secret_key=xxxxxxxx \
    region=us-east-1

# Create role
vault write aws/roles/deploy-role \
    credential_type=iam_user \
    policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["arn:aws:s3:::my-bucket/*"]
    }
  ]
}
EOF

# Generate credentials
vault read aws/creds/deploy-role
```

## PKI Secrets Engine

### Certificate Authority
```bash
# Enable PKI
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki

# Generate root CA
vault write pki/root/generate/internal \
    common_name="Example Root CA" \
    ttl=87600h

# Create role
vault write pki/roles/server-cert \
    allowed_domains="example.com" \
    allow_subdomains=true \
    max_ttl="720h"

# Issue certificate
vault write pki/issue/server-cert \
    common_name="api.example.com" \
    ttl="24h"
```

## Transit Secrets Engine

### Encryption as a Service
```bash
# Enable transit
vault secrets enable transit

# Create encryption key
vault write -f transit/keys/myapp-key

# Encrypt data
vault write transit/encrypt/myapp-key \
    plaintext=$(echo "secret data" | base64)

# Decrypt data
vault write transit/decrypt/myapp-key \
    ciphertext="vault:v1:xxxxx"

# Rotate key
vault write -f transit/keys/myapp-key/rotate
```
