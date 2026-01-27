# Vault Policy Guide

## Policy Syntax

```hcl
# Basic policy structure
path "secret/data/myapp/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

## Capabilities

| Capability | HTTP Verb | Description |
|------------|-----------|-------------|
| `create` | POST/PUT | Create new data |
| `read` | GET | Read data |
| `update` | POST/PUT | Update existing data |
| `delete` | DELETE | Delete data |
| `list` | LIST | List keys |
| `sudo` | - | Root-protected paths |
| `deny` | - | Explicitly deny access |

## Common Policies

### Application Read-Only
```hcl
# app-readonly.hcl
path "secret/data/myapp/*" {
  capabilities = ["read", "list"]
}

path "secret/metadata/myapp/*" {
  capabilities = ["read", "list"]
}
```

### Developer Policy
```hcl
# developer.hcl
path "secret/data/dev/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/staging/*" {
  capabilities = ["read", "list"]
}

# Deny production access
path "secret/data/prod/*" {
  capabilities = ["deny"]
}
```

### CI/CD Pipeline
```hcl
# cicd.hcl
# Read deployment secrets
path "secret/data/deploy/*" {
  capabilities = ["read"]
}

# Generate dynamic database credentials
path "database/creds/myapp-role" {
  capabilities = ["read"]
}

# Sign SSH keys
path "ssh-client-signer/sign/deploy-role" {
  capabilities = ["create", "update"]
}
```

### Admin Policy
```hcl
# admin.hcl
# Manage secrets engines
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage policies
path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage auth methods
path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# View audit logs
path "sys/audit" {
  capabilities = ["read", "list"]
}
```

## Policy Templates

### Using Templating
```hcl
# Per-user secrets path
path "secret/data/users/{{identity.entity.name}}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Team-based access
path "secret/data/teams/{{identity.groups.names}}/*" {
  capabilities = ["read", "list"]
}
```

## Policy Management

```bash
# Write policy
vault policy write myapp-policy myapp-policy.hcl

# List policies
vault policy list

# Read policy
vault policy read myapp-policy

# Delete policy
vault policy delete myapp-policy

# Test policy (requires root)
vault token create -policy=myapp-policy
```
