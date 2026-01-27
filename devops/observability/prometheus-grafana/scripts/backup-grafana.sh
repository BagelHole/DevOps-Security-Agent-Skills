#!/bin/bash
# Grafana Dashboard Backup Script
# Usage: ./backup-grafana.sh [grafana-url] [api-key] [output-dir]

set -euo pipefail

GRAFANA_URL="${1:-http://localhost:3000}"
API_KEY="${2:-$GRAFANA_API_KEY}"
OUTPUT_DIR="${3:-./grafana-backup-$(date +%Y%m%d)}"

if [ -z "$API_KEY" ]; then
    echo "Error: API key required. Set GRAFANA_API_KEY or pass as argument."
    exit 1
fi

mkdir -p "$OUTPUT_DIR/dashboards"
mkdir -p "$OUTPUT_DIR/datasources"
mkdir -p "$OUTPUT_DIR/folders"

echo "========================================="
echo "Grafana Backup"
echo "URL: $GRAFANA_URL"
echo "Output: $OUTPUT_DIR"
echo "========================================="
echo ""

# Backup datasources
echo "Backing up datasources..."
curl -s -H "Authorization: Bearer $API_KEY" \
    "$GRAFANA_URL/api/datasources" > "$OUTPUT_DIR/datasources/datasources.json"
DS_COUNT=$(jq length "$OUTPUT_DIR/datasources/datasources.json")
echo "  Backed up $DS_COUNT datasources"

# Backup folders
echo "Backing up folders..."
curl -s -H "Authorization: Bearer $API_KEY" \
    "$GRAFANA_URL/api/folders" > "$OUTPUT_DIR/folders/folders.json"
FOLDER_COUNT=$(jq length "$OUTPUT_DIR/folders/folders.json")
echo "  Backed up $FOLDER_COUNT folders"

# Get all dashboards
echo "Backing up dashboards..."
DASHBOARDS=$(curl -s -H "Authorization: Bearer $API_KEY" \
    "$GRAFANA_URL/api/search?type=dash-db")

DASH_COUNT=0
echo "$DASHBOARDS" | jq -r '.[].uid' | while read uid; do
    DASH=$(curl -s -H "Authorization: Bearer $API_KEY" \
        "$GRAFANA_URL/api/dashboards/uid/$uid")
    
    TITLE=$(echo "$DASH" | jq -r '.dashboard.title' | tr ' /' '_')
    echo "$DASH" > "$OUTPUT_DIR/dashboards/${TITLE}_${uid}.json"
    echo "  - $TITLE"
    DASH_COUNT=$((DASH_COUNT + 1))
done

echo ""
echo "Backup complete!"
echo "Location: $OUTPUT_DIR"
echo ""
echo "To restore:"
echo "  1. Datasources: POST to /api/datasources"
echo "  2. Folders: POST to /api/folders"
echo "  3. Dashboards: POST to /api/dashboards/db"
