---
name: supply-chain-attack-response
description: Detect, respond to, and prevent software supply chain attacks on package registries, container images, and CI/CD pipelines with lockfile auditing, provenance verification, and emergency response playbooks.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Supply Chain Attack Response

Software supply chain attacks target the dependencies, build systems, and distribution channels that developers trust implicitly. When a package on PyPI, npm, or crates.io is compromised, every downstream consumer inherits the malicious payload. This skill provides detection techniques, emergency response playbooks, and hardening strategies to protect your software supply chain end to end.

---

## 1. When to Use This Skill

Invoke this skill when any of the following apply:

- A dependency you consume has been flagged as compromised (e.g., advisories on OSV.dev, GitHub Advisory Database, or vendor disclosure).
- You observe suspicious behavior from a dependency: unexpected network calls, file system writes outside its scope, or new post-install scripts.
- You are conducting a periodic supply chain security audit.
- A CI/CD pipeline is behaving unexpectedly after a dependency update.
- You are onboarding a new third-party dependency and want to verify its provenance.
- You need to respond to an incident such as a typosquatted package or registry account takeover.
- You are implementing SLSA compliance or need to generate build provenance.

---

## 2. Detection

### 2.1 npm Audit

```bash
# Full audit of installed packages
npm audit

# JSON output for programmatic processing
npm audit --json | jq '.vulnerabilities | to_entries[] | select(.value.severity == "critical")'

# Fix automatically where possible
npm audit fix

# Check for known malicious packages via Socket.dev CLI
npx socket scan --package-lock package-lock.json
```

### 2.2 pip Audit

```bash
# Install pip-audit (maintained by Google/OSSF)
pip install pip-audit

# Audit current environment against OSV.dev
pip-audit

# Audit a requirements file directly
pip-audit -r requirements.txt --output json

# Check for typosquatting with bandersnatch or custom script
pip-audit --strict --desc on
```

### 2.3 Cargo Audit

```bash
# Install cargo-audit
cargo install cargo-audit

# Run audit against RustSec Advisory Database
cargo audit

# JSON output for CI integration
cargo audit --json

# Check for yanked crates
cargo audit --deny yanked
```

### 2.4 Sigstore / Cosign Verification

```bash
# Verify a container image signature with cosign
cosign verify \
  --certificate-identity "https://github.com/myorg/myrepo/.github/workflows/build.yml@refs/heads/main" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/myorg/myimage:latest

# Verify an artifact with sigstore-python
pip install sigstore
python -m sigstore verify identity \
  --cert-identity "release@example.com" \
  --cert-oidc-issuer "https://accounts.google.com" \
  artifact.tar.gz
```

### 2.5 SLSA Provenance Checks

```bash
# Install slsa-verifier
go install github.com/slsa-framework/slsa-verifier/v2/cli/slsa-verifier@latest

# Verify provenance of a binary
slsa-verifier verify-artifact my-binary \
  --provenance-path my-binary.intoto.jsonl \
  --source-uri github.com/myorg/myrepo \
  --source-tag v1.2.3
```

---

## 3. Emergency Response Playbook

When a dependency is confirmed compromised, execute these steps in order.

### Step 1: Contain -- Pin and Freeze

```bash
# Pin the last known-good version immediately in package.json
npm install <package>@<safe-version> --save-exact

# For pip, pin with hash verification
pip download <package>==<safe-version> --require-hashes -d ./vendor/

# For cargo, pin in Cargo.toml
# Replace: some_crate = "^1.2" with:
# some_crate = "=1.2.3"
cargo update -p some_crate --precise 1.2.3
```

### Step 2: Audit Exposure

```bash
# Determine which versions you pulled and when
# npm
npm ls <compromised-package>
cat package-lock.json | jq '.packages | to_entries[] | select(.key | contains("<compromised-package>"))'

# pip
pip show <compromised-package>
pip cache list <compromised-package>

# Check git history for when the dependency version changed
git log --all -p -- package-lock.json | grep -A2 -B2 "<compromised-package>"
```

### Step 3: Scan for Indicators of Compromise

```bash
# Search for known IOCs from the advisory
grep -r "suspicious-domain.com" ./node_modules/<compromised-package>/
grep -r "eval(atob" ./node_modules/<compromised-package>/

# Check for unexpected post-install scripts
cat node_modules/<compromised-package>/package.json | jq '.scripts'

# For Python packages, inspect setup.py and __init__.py
find ~/.local/lib/python*/site-packages/<compromised-package>/ -name "*.py" \
  | xargs grep -l "subprocess\|os.system\|exec(\|eval("
```

### Step 4: Notify Stakeholders

```text
SUBJECT: [SECURITY INCIDENT] Compromised dependency: <package-name>

SEVERITY: Critical
IMPACT: <package-name> versions <affected-range> contain malicious code.
AFFECTED SYSTEMS: <list of repos/services consuming this dependency>
STATUS: Contained -- pinned to safe version <safe-version>

ACTIONS TAKEN:
1. Pinned all repositories to last known-good version
2. Initiated audit of all systems that pulled affected versions
3. Scanning for indicators of compromise

RECOMMENDED ACTIONS:
- Do NOT deploy any build that consumed affected versions
- Review CI/CD logs for the timeframe <start> to <end>
- Rotate any secrets that were accessible to the build environment
```

### Step 5: Replace or Fork

```bash
# If the package maintainer account was compromised, fork the last safe version
git clone https://github.com/original-author/<package>.git
cd <package>
git checkout v<safe-version>
# Publish to your private registry or vendor directly

# For npm, point to your fork via package.json
# "dependencies": { "<package>": "git+https://github.com/yourorg/<package>.git#v1.2.3" }
```

---

## 4. Lockfile Auditing

Lockfiles are your first line of defense. Tampered or inconsistent lockfiles indicate something is wrong.

### 4.1 Verify Lockfile Integrity

```bash
# npm: ensure lockfile matches package.json (fails CI if out of sync)
npm ci

# Yarn: check lockfile integrity
yarn install --frozen-lockfile

# pip: generate a hash-locked requirements file
pip-compile --generate-hashes requirements.in -o requirements.txt

# Verify no unexpected changes in lockfile during PR
git diff --name-only origin/main...HEAD | grep -E "(package-lock|yarn.lock|Cargo.lock|requirements.txt)"
```

### 4.2 Detect Typosquatting

```bash
# Use the socket CLI to check for typosquatting risk
npx socket scan --package-lock package-lock.json

# Python: check package names against popular packages
pip-audit -r requirements.txt 2>&1 | grep -i "typosquat"

# Custom check: compare package names to known popular packages
# Flag anything with edit distance <= 2 from a top-1000 package
python3 -c "
import json, sys
from difflib import SequenceMatcher
with open('package-lock.json') as f:
    lock = json.load(f)
popular = ['express','lodash','react','axios','chalk','debug','commander','inquirer']
for pkg in lock.get('packages', {}):
    name = pkg.split('node_modules/')[-1] if 'node_modules/' in pkg else pkg
    for p in popular:
        ratio = SequenceMatcher(None, name, p).ratio()
        if 0.75 < ratio < 1.0 and name != p:
            print(f'WARNING: {name} is suspiciously similar to {p} (similarity: {ratio:.2f})')
"
```

### 4.3 Lockfile Diff in CI

```yaml
# .github/workflows/lockfile-check.yml
name: Lockfile Audit
on: pull_request
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Check for lockfile changes
        run: |
          LOCKFILES="package-lock.json yarn.lock pnpm-lock.yaml Cargo.lock requirements.txt poetry.lock"
          for f in $LOCKFILES; do
            if git diff --name-only origin/main...HEAD | grep -q "$f"; then
              echo "::warning::Lockfile $f was modified -- review dependency changes carefully"
              git diff origin/main...HEAD -- "$f" | head -100
            fi
          done
      - name: Run npm audit
        if: hashFiles('package-lock.json') != ''
        run: npm audit --audit-level=high
```

---

## 5. Package Pinning and Verification

### 5.1 pip Hash Checking

```text
# requirements.txt with hashes (generated by pip-compile --generate-hashes)
requests==2.31.0 \
    --hash=sha256:58cd2187c01e70e6e26505bca751777aa9f2ee0b7f4300988b709f44e013003eb \
    --hash=sha256:942c5a758f98d790eaed1a29cb6eefc7f0edf3fcb0fce8afe0f44546e1
```

```bash
# Install with mandatory hash verification
pip install --require-hashes -r requirements.txt

# Generate hashes for existing requirements
pip-compile --generate-hashes requirements.in
```

### 5.2 npm Package Integrity

```bash
# npm automatically verifies integrity hashes in package-lock.json
# Ensure your lockfile contains integrity fields:
cat package-lock.json | jq '.packages | to_entries[] | select(.value.integrity == null) | .key'

# Enable strict engine and audit checks in .npmrc
cat >> .npmrc << 'EOF'
engine-strict=true
audit=true
audit-level=high
EOF
```

### 5.3 cargo-vet for Rust

```bash
# Install cargo-vet
cargo install cargo-vet

# Initialize in your project
cargo vet init

# Certify a crate after review
cargo vet certify serde 1.0.193

# Import audit results from trusted organizations
cargo vet trust --all mozilla
cargo vet trust --all google

# Run verification in CI
cargo vet check
```

---

## 6. Container Image Verification

### 6.1 Cosign Sign and Verify

```bash
# Sign an image (keyless via Sigstore/Fulcio in CI)
cosign sign ghcr.io/myorg/myimage@sha256:abc123...

# Verify with expected identity
cosign verify \
  --certificate-identity-regexp "https://github.com/myorg/.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/myorg/myimage:latest

# Verify and extract attestations
cosign verify-attestation \
  --type slsaprovenance \
  --certificate-identity-regexp "https://github.com/myorg/.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/myorg/myimage:latest | jq '.payload' | base64 -d | jq .
```

### 6.2 Kyverno Policy -- Require Signed Images

```yaml
# kyverno-require-signed-images.yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-signed-images
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: verify-image-signature
      match:
        any:
          - resources:
              kinds:
                - Pod
      verifyImages:
        - imageReferences:
            - "ghcr.io/myorg/*"
          attestors:
            - entries:
                - keyless:
                    subject: "https://github.com/myorg/*"
                    issuer: "https://token.actions.githubusercontent.com"
                    rekor:
                      url: https://rekor.sigstore.dev
```

```bash
# Apply the policy
kubectl apply -f kyverno-require-signed-images.yaml

# Test: this unsigned image should be rejected
kubectl run test --image=ghcr.io/myorg/unsigned-image:latest
# Expected: admission webhook denies the request
```

---

## 7. CI/CD Pipeline Hardening

### 7.1 Pin GitHub Actions by SHA

```yaml
# BAD: mutable tag, can be hijacked
- uses: actions/checkout@v4

# GOOD: pinned to exact commit SHA
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

```bash
# Use pin-github-action to automate pinning
npm install -g pin-github-action
pin-github-action .github/workflows/*.yml
```

### 7.2 Isolated Runners

```yaml
# Use ephemeral self-hosted runners that are destroyed after each job
jobs:
  build:
    runs-on: self-hosted
    container:
      image: ghcr.io/myorg/build-env:latest@sha256:abc123...
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
      - name: Build in isolated container
        run: |
          # No access to host filesystem or network beyond what's needed
          make build
```

### 7.3 OIDC for Cloud Authentication (No Long-Lived Secrets)

```yaml
# GitHub Actions OIDC with AWS -- no static credentials stored
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502 # v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-deploy
          aws-region: us-east-1
      - run: aws s3 cp build/ s3://my-bucket/ --recursive
```

### 7.4 Restrict Workflow Permissions

```yaml
# At the top of every workflow, use least-privilege permissions
permissions:
  contents: read
  packages: read

# Never grant write permissions globally; scope them per job
jobs:
  publish:
    permissions:
      contents: read
      packages: write
```

---

## 8. SLSA Framework Implementation

### 8.1 SLSA Levels Overview

| Level | Requirement |
|-------|-------------|
| SLSA 1 | Build process is documented and generates provenance |
| SLSA 2 | Provenance is generated by a hosted build service and is authenticated |
| SLSA 3 | Build platform is hardened, provenance is non-falsifiable |

### 8.2 SLSA Level 1 -- Generate Provenance

```yaml
# .github/workflows/slsa-build.yml
name: SLSA Build
on:
  push:
    tags: ["v*"]
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      digest: ${{ steps.hash.outputs.digest }}
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
      - name: Build artifact
        run: |
          make build
          cp dist/my-binary ./my-binary
      - name: Generate digest
        id: hash
        run: |
          DIGEST=$(sha256sum my-binary | cut -d ' ' -f1)
          echo "digest=$DIGEST" >> "$GITHUB_OUTPUT"
      - uses: actions/upload-artifact@v4
        with:
          name: my-binary
          path: my-binary
```

### 8.3 SLSA Level 2-3 -- Use the SLSA GitHub Generator

```yaml
  provenance:
    needs: build
    permissions:
      actions: read
      id-token: write
      contents: write
    uses: slsa-framework/slsa-github-generator/.github/workflows/generator_generic_slsa3.yml@v2.0.0
    with:
      base64-subjects: |
        ${{ needs.build.outputs.digest }} my-binary
      upload-assets: true
```

### 8.4 Verify SLSA Provenance

```bash
# Download the provenance and binary from the release
gh release download v1.2.3 -p "my-binary" -p "my-binary.intoto.jsonl"

# Verify
slsa-verifier verify-artifact my-binary \
  --provenance-path my-binary.intoto.jsonl \
  --source-uri github.com/myorg/myrepo \
  --source-tag v1.2.3

echo $?  # 0 = verified successfully
```

---

## 9. Dependency Firewall

### 9.1 Artifactory Remote Repository with Allow List

```yaml
# artifactory-remote-npm.yaml
apiVersion: v1
kind: RemoteRepository
metadata:
  name: npm-remote
spec:
  packageType: npm
  url: https://registry.npmjs.org
  includesPattern: |
    express/**
    lodash/**
    react/**
    @types/**
  excludesPattern: |
    *malicious*
    *typosquat*
  xrayIndex: true
  blockMismatchingMimeTypes: true
  enableTokenAuthentication: true
```

### 9.2 Nexus Repository Firewall Rules

```bash
# Enable Nexus Firewall audit on a proxy repository
curl -u admin:$NEXUS_PASSWORD -X PUT \
  "https://nexus.internal/service/rest/v1/security/content-selectors" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "block-suspicious-pypi",
    "description": "Block packages with no maintainer history",
    "expression": "format == \"pypi\" and coordinate.age < 7"
  }'
```

### 9.3 Verdaccio Private npm Registry

```yaml
# verdaccio config.yaml
storage: /verdaccio/storage
uplinks:
  npmjs:
    url: https://registry.npmjs.org/
    cache: true
    maxage: 30m
packages:
  '@myorg/*':
    access: $authenticated
    publish: $authenticated
    proxy: []           # never proxy internal packages
  '**':
    access: $authenticated
    publish: $deny       # block publishing public package names
    proxy: npmjs
  # Block known malicious packages
  'event-stream':
    access: $deny
    publish: $deny
```

---

## 10. Monitoring and Alerting

### 10.1 Detect New Dependencies in Pull Requests

```yaml
# .github/workflows/dependency-review.yml
name: Dependency Review
on: pull_request
permissions:
  contents: read
  pull-requests: write
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
      - uses: actions/dependency-review-action@4901385134134e04cec5fbe5ddfe3b2c5bd5d976 # v4
        with:
          fail-on-severity: high
          deny-licenses: GPL-3.0, AGPL-3.0
          comment-summary-in-pr: always
          warn-only: false
```

### 10.2 OSV.dev Integration

```bash
# Install osv-scanner
go install github.com/google/osv-scanner/cmd/osv-scanner@latest

# Scan a project directory (auto-detects lockfiles)
osv-scanner -r /path/to/project

# Scan a specific lockfile
osv-scanner --lockfile=package-lock.json

# Scan a Docker image
osv-scanner --docker myimage:latest

# Output as JSON for CI processing
osv-scanner -r /path/to/project --format json | jq '.results[].packages[].vulnerabilities[] | .id'
```

### 10.3 Dependabot Configuration

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
      - "security"
    # Group minor/patch updates but keep major separate for review
    groups:
      production-dependencies:
        dependency-type: "production"
        update-types: ["minor", "patch"]
      dev-dependencies:
        dependency-type: "development"
        update-types: ["minor", "patch"]

  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### 10.4 Custom Webhook Alert for New Dependencies

```bash
#!/usr/bin/env bash
# alert-new-deps.sh -- run in CI on PRs to detect newly added dependencies
set -euo pipefail

BASE_BRANCH="${1:-origin/main}"
LOCKFILE="package-lock.json"

NEW_DEPS=$(diff <(git show "$BASE_BRANCH:$LOCKFILE" 2>/dev/null | jq -r '.packages | keys[]' | sort) \
               <(jq -r '.packages | keys[]' "$LOCKFILE" | sort) \
           | grep "^>" | sed 's/^> //' || true)

if [ -n "$NEW_DEPS" ]; then
  echo "New dependencies detected:"
  echo "$NEW_DEPS"

  # Send to Slack
  curl -s -X POST "$SLACK_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"text\": \"New dependencies added in PR #${PR_NUMBER}:\n\`\`\`${NEW_DEPS}\`\`\`\",
      \"channel\": \"#security-alerts\"
    }"
fi
```

---

## 11. Post-Incident Response

### 11.1 Forensics Checklist

```text
[ ] Identify the exact compromised package version(s)
[ ] Determine the time window of exposure (first install to detection)
[ ] List all repositories and services that consumed the package
[ ] Check CI/CD build logs for the exposure window
[ ] Inspect runtime logs for outbound connections to unknown hosts
[ ] Review process execution logs for unexpected child processes
[ ] Check for modifications to other files in node_modules/site-packages
[ ] Verify no additional packages were installed as transitive deps
[ ] Dump and analyze DNS query logs for the exposure period
[ ] Check for new cron jobs, systemd services, or scheduled tasks
[ ] Audit all secrets/tokens that were accessible to the build environment
```

### 11.2 Blast Radius Assessment

```bash
#!/usr/bin/env bash
# blast-radius.sh -- assess how widely a compromised package spread
set -euo pipefail

COMPROMISED_PKG="$1"
COMPROMISED_VERSIONS="$2"  # comma-separated, e.g., "1.2.3,1.2.4"

echo "=== Blast Radius Assessment for $COMPROMISED_PKG ==="

# Check all repos in the org
for repo in $(gh repo list myorg --json name -q '.[].name'); do
  echo "--- Checking $repo ---"

  # Check package-lock.json
  LOCK=$(gh api "repos/myorg/$repo/contents/package-lock.json" \
    --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || true)

  if echo "$LOCK" | grep -q "\"$COMPROMISED_PKG\""; then
    VERSION=$(echo "$LOCK" | jq -r ".packages[\"node_modules/$COMPROMISED_PKG\"].version // empty")
    if echo "$COMPROMISED_VERSIONS" | grep -q "$VERSION"; then
      echo "AFFECTED: $repo uses $COMPROMISED_PKG@$VERSION"
    fi
  fi
done
```

### 11.3 Secret Rotation After Compromise

```bash
# Rotate all secrets that were accessible during the exposure window

# 1. Rotate cloud provider credentials
aws iam create-access-key --user-name ci-deploy
aws iam delete-access-key --user-name ci-deploy --access-key-id OLD_KEY_ID

# 2. Rotate GitHub tokens
gh auth refresh

# 3. Rotate database credentials
kubectl create secret generic db-credentials \
  --from-literal=password="$(openssl rand -base64 32)" \
  --dry-run=client -o yaml | kubectl apply -f -

# 4. Rotate npm/PyPI publish tokens
npm token revoke <old-token>
npm token create --read-only

# 5. Invalidate all active sessions/JWTs
# Application-specific -- trigger a key rotation in your auth service
```

### 11.4 Communication Templates

```text
--- INTERNAL INCIDENT REPORT ---

Incident ID: SC-YYYY-NNN
Date Detected: YYYY-MM-DD HH:MM UTC
Package: <name>@<version>
Registry: npm / PyPI / crates.io
Advisory: <link to CVE or advisory>

Timeline:
  - YYYY-MM-DD HH:MM: Compromised version published to registry
  - YYYY-MM-DD HH:MM: First installation in our environment (from CI logs)
  - YYYY-MM-DD HH:MM: Compromise detected via <audit tool / advisory / manual review>
  - YYYY-MM-DD HH:MM: Pinned to safe version across all repos
  - YYYY-MM-DD HH:MM: Completed IOC scan -- no evidence of exploitation
  - YYYY-MM-DD HH:MM: All exposed secrets rotated

Blast Radius:
  - Repositories affected: N
  - Production deployments with compromised version: N
  - Secrets potentially exposed: <list>

Root Cause:
  <Maintainer account takeover / malicious maintainer / build system compromise>

Remediation:
  1. Pinned to safe version
  2. Rotated all potentially exposed secrets
  3. Deployed clean builds to production
  4. Added package to monitoring watch list

Preventive Measures:
  1. Enabled hash-pinning for all dependencies
  2. Added dependency-review-action to all repos
  3. Configured Artifactory proxy with allowlist
  4. Scheduled quarterly supply chain audits
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Audit npm | `npm audit --json` |
| Audit pip | `pip-audit -r requirements.txt` |
| Audit cargo | `cargo audit` |
| Scan with OSV | `osv-scanner -r .` |
| Verify cosign signature | `cosign verify --certificate-identity-regexp ... <image>` |
| Verify SLSA provenance | `slsa-verifier verify-artifact ...` |
| Pin GitHub Actions | `pin-github-action .github/workflows/*.yml` |
| Check lockfile drift | `npm ci` (fails if lockfile is out of sync) |
| Generate pip hashes | `pip-compile --generate-hashes requirements.in` |
| Cargo vet check | `cargo vet check` |
