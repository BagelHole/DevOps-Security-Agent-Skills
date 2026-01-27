#!/bin/bash
# Vault Backup Script (Raft Storage)
# Usage: ./vault-backup.sh [output-dir]

set -euo pipefail

OUTPUT_DIR="${1:-./vault-backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$OUTPUT_DIR/vault-snapshot-$TIMESTAMP.snap"

mkdir -p "$OUTPUT_DIR"

echo "========================================="
echo "Vault Raft Snapshot Backup"
echo "Output: $BACKUP_FILE"
echo "========================================="
echo ""

# Check Vault status
if ! vault status &>/dev/null; then
    echo "Error: Cannot connect to Vault or Vault is sealed"
    exit 1
fi

# Take snapshot
echo "Creating snapshot..."
vault operator raft snapshot save "$BACKUP_FILE"

if [ -f "$BACKUP_FILE" ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "Snapshot created successfully!"
    echo "File: $BACKUP_FILE"
    echo "Size: $SIZE"
else
    echo "Error: Snapshot creation failed"
    exit 1
fi

# Verify snapshot
echo ""
echo "Verifying snapshot..."
vault operator raft snapshot inspect "$BACKUP_FILE" | head -20

# Cleanup old backups (keep last 7)
echo ""
echo "Cleaning up old backups (keeping last 7)..."
ls -t "$OUTPUT_DIR"/vault-snapshot-*.snap 2>/dev/null | tail -n +8 | xargs -r rm -v

echo ""
echo "========================================="
echo "Backup complete"
echo ""
echo "To restore:"
echo "  vault operator raft snapshot restore $BACKUP_FILE"
echo "========================================="
