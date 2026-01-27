#!/bin/bash
# UFW Firewall Setup Script
# Usage: ./setup-ufw.sh [--apply]

set -euo pipefail

APPLY="${1:-}"

if [ "$APPLY" != "--apply" ]; then
    echo "DRY RUN MODE - showing commands only"
    echo "Run with --apply to execute"
    echo ""
fi

run_cmd() {
    if [ "$APPLY" == "--apply" ]; then
        eval "$1"
    else
        echo "[DRY RUN] $1"
    fi
}

echo "========================================="
echo "UFW Firewall Setup"
echo "========================================="
echo ""

# Reset UFW
echo "Resetting UFW to defaults..."
run_cmd "ufw --force reset"

# Set default policies
echo ""
echo "Setting default policies..."
run_cmd "ufw default deny incoming"
run_cmd "ufw default allow outgoing"

# Essential services
echo ""
echo "Allowing essential services..."

# SSH (rate limited)
run_cmd "ufw limit ssh comment 'SSH with rate limiting'"

# Common services (uncomment as needed)
echo ""
echo "Common service rules (customize as needed):"

# Web server
# run_cmd "ufw allow 80/tcp comment 'HTTP'"
# run_cmd "ufw allow 443/tcp comment 'HTTPS'"

# Database (restrict to specific IPs)
# run_cmd "ufw allow from 10.0.0.0/8 to any port 5432 comment 'PostgreSQL from internal'"
# run_cmd "ufw allow from 10.0.0.0/8 to any port 3306 comment 'MySQL from internal'"

# Application ports
# run_cmd "ufw allow 8080/tcp comment 'Application'"

# Enable logging
echo ""
echo "Enabling logging..."
run_cmd "ufw logging medium"

# Enable firewall
echo ""
echo "Enabling UFW..."
run_cmd "ufw --force enable"

# Show status
echo ""
echo "Final status:"
if [ "$APPLY" == "--apply" ]; then
    ufw status verbose
fi

echo ""
echo "========================================="
echo "Setup complete"
echo "========================================="
