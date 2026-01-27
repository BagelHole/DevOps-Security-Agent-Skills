# Vault Server Configuration
# /etc/vault.d/vault.hcl

# Cluster name
cluster_name = "production"

# Storage backend (Raft for HA)
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-1"
  
  retry_join {
    leader_api_addr = "https://vault-2.example.com:8200"
  }
  retry_join {
    leader_api_addr = "https://vault-3.example.com:8200"
  }
}

# Listener configuration
listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_cert_file   = "/opt/vault/tls/vault.crt"
  tls_key_file    = "/opt/vault/tls/vault.key"
  
  # TLS settings
  tls_min_version = "tls12"
  tls_cipher_suites = "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
}

# API address
api_addr     = "https://vault.example.com:8200"
cluster_addr = "https://vault-1.example.com:8201"

# UI
ui = true

# Telemetry
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = true
}

# Audit logging
# Enable via API after init:
# vault audit enable file file_path=/var/log/vault/audit.log

# Seal configuration (Auto-unseal with AWS KMS)
# seal "awskms" {
#   region     = "us-east-1"
#   kms_key_id = "alias/vault-unseal-key"
# }

# Performance settings
max_lease_ttl         = "768h"
default_lease_ttl     = "768h"
disable_mlock         = false
disable_cache         = false

# Plugin directory
plugin_directory = "/opt/vault/plugins"
