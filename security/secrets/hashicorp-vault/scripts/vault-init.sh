#!/bin/bash
# Vault Initialization and Unseal Script
# Usage: ./vault-init.sh [vault-addr]

set -euo pipefail

export VAULT_ADDR="${1:-http://127.0.0.1:8200}"

echo "========================================="
echo "Vault Initialization"
echo "Address: $VAULT_ADDR"
echo "========================================="
echo ""

# Check if Vault is already initialized
INIT_STATUS=$(vault status -format=json 2>/dev/null | jq -r '.initialized' || echo "error")

if [ "$INIT_STATUS" == "true" ]; then
    echo "Vault is already initialized"
    SEALED=$(vault status -format=json | jq -r '.sealed')
    if [ "$SEALED" == "true" ]; then
        echo "Vault is sealed. Use unseal keys to unseal."
    else
        echo "Vault is unsealed and ready."
    fi
    exit 0
fi

if [ "$INIT_STATUS" == "error" ]; then
    echo "Error: Cannot connect to Vault at $VAULT_ADDR"
    exit 1
fi

# Initialize Vault
echo "Initializing Vault..."
echo ""

# Initialize with 5 key shares, 3 required to unseal
INIT_OUTPUT=$(vault operator init \
    -key-shares=5 \
    -key-threshold=3 \
    -format=json)

# Save keys securely
echo "$INIT_OUTPUT" > vault-init-keys.json
chmod 600 vault-init-keys.json

echo "Vault initialized successfully!"
echo ""
echo "IMPORTANT: vault-init-keys.json contains your unseal keys and root token"
echo "Store these securely and distribute unseal keys to different people"
echo ""

# Extract keys
UNSEAL_KEY_1=$(echo "$INIT_OUTPUT" | jq -r '.unseal_keys_b64[0]')
UNSEAL_KEY_2=$(echo "$INIT_OUTPUT" | jq -r '.unseal_keys_b64[1]')
UNSEAL_KEY_3=$(echo "$INIT_OUTPUT" | jq -r '.unseal_keys_b64[2]')
ROOT_TOKEN=$(echo "$INIT_OUTPUT" | jq -r '.root_token')

# Unseal Vault
echo "Unsealing Vault..."
vault operator unseal "$UNSEAL_KEY_1" >/dev/null
vault operator unseal "$UNSEAL_KEY_2" >/dev/null
vault operator unseal "$UNSEAL_KEY_3" >/dev/null

echo "Vault unsealed successfully!"
echo ""
echo "Root Token: $ROOT_TOKEN"
echo ""
echo "Login with: vault login $ROOT_TOKEN"
echo ""
echo "========================================="
echo "Next steps:"
echo "1. Store unseal keys securely (different locations)"
echo "2. Create AppRole or other auth methods"
echo "3. Enable audit logging"
echo "4. Configure secrets engines"
echo "========================================="
