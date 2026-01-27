# Vulnerability Scanner Comparison

## Container Image Scanners

| Tool | License | Speed | Database | CI Integration |
|------|---------|-------|----------|----------------|
| **Trivy** | Apache 2.0 | Fast | NVD, Red Hat, etc. | Excellent |
| **Grype** | Apache 2.0 | Fast | Anchore DB | Good |
| **Clair** | Apache 2.0 | Medium | NVD, Alpine, etc. | Good |
| **Snyk** | Commercial | Fast | Snyk DB | Excellent |
| **Docker Scout** | Commercial | Fast | Docker DB | Native |

## Recommended: Trivy

### Installation
```bash
# Homebrew
brew install trivy

# APT
apt-get install trivy

# Docker
docker run aquasec/trivy image nginx:latest
```

### Basic Usage
```bash
# Scan image
trivy image nginx:latest

# Scan with severity filter
trivy image --severity HIGH,CRITICAL nginx:latest

# Scan and fail on vulnerabilities
trivy image --exit-code 1 --severity CRITICAL nginx:latest

# JSON output
trivy image -f json -o results.json nginx:latest

# Scan filesystem
trivy fs /path/to/project

# Scan Kubernetes
trivy k8s --report summary cluster
```

### GitHub Actions
```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'myapp:${{ github.sha }}'
    format: 'sarif'
    output: 'trivy-results.sarif'
    severity: 'CRITICAL,HIGH'
    
- name: Upload Trivy scan results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: 'trivy-results.sarif'
```

## Dependency Scanners

| Tool | Languages | License |
|------|-----------|---------|
| **npm audit** | JavaScript | Free |
| **pip-audit** | Python | Free |
| **bundle audit** | Ruby | Free |
| **cargo audit** | Rust | Free |
| **Snyk** | Multi | Commercial |
| **Dependabot** | Multi | Free (GitHub) |
| **OWASP Dependency-Check** | Multi | Apache 2.0 |

## Infrastructure as Code Scanners

| Tool | Targets | License |
|------|---------|---------|
| **tfsec** | Terraform | MIT |
| **checkov** | TF, CloudFormation, K8s | Apache 2.0 |
| **kics** | Multi IaC | Apache 2.0 |
| **kubesec** | Kubernetes | Apache 2.0 |

## CVSS Score Reference

| Score | Severity |
|-------|----------|
| 0.0 | None |
| 0.1-3.9 | Low |
| 4.0-6.9 | Medium |
| 7.0-8.9 | High |
| 9.0-10.0 | Critical |
