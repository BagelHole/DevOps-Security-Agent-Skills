# DAST Tools Reference

## Tool Comparison

| Tool | Type | License | Best For |
|------|------|---------|----------|
| **OWASP ZAP** | Proxy/Scanner | Apache 2.0 | General DAST |
| **Nuclei** | Template-based | MIT | Vulnerability checks |
| **Nikto** | Web scanner | GPL | Quick scans |
| **Burp Suite** | Proxy/Scanner | Commercial | Manual testing |

## OWASP ZAP

### CLI Scanning
```bash
# Quick scan
docker run -t owasp/zap2docker-stable zap-baseline.py -t https://target.com

# Full scan
docker run -t owasp/zap2docker-stable zap-full-scan.py -t https://target.com

# API scan
docker run -t owasp/zap2docker-stable zap-api-scan.py \
  -t https://target.com/openapi.json -f openapi
```

### Automation Framework
```yaml
# zap-config.yaml
env:
  contexts:
    - name: "Default Context"
      urls: ["https://target.com"]
      authentication:
        method: "form"
        parameters:
          loginUrl: "https://target.com/login"
          loginRequestData: "user={%username%}&pass={%password%}"
jobs:
  - type: spider
    parameters:
      maxDuration: 5
  - type: activeScan
    parameters:
      maxScanDurationInMins: 60
  - type: report
    parameters:
      template: "traditional-html"
      reportFile: "zap-report.html"
```

## Nuclei

```bash
# Install
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Scan with all templates
nuclei -u https://target.com

# Specific templates
nuclei -u https://target.com -t cves/
nuclei -u https://target.com -t exposures/

# Critical and high only
nuclei -u https://target.com -severity critical,high

# Output
nuclei -u https://target.com -json -o results.json
```

### Custom Template
```yaml
id: custom-check
info:
  name: Custom Security Check
  severity: high
requests:
  - method: GET
    path:
      - "{{BaseURL}}/admin"
    matchers:
      - type: status
        status:
          - 200
```

## CI Integration

```yaml
# GitHub Actions
- name: OWASP ZAP Scan
  uses: zaproxy/action-baseline@v0.9.0
  with:
    target: 'https://target.com'
    rules_file_name: '.zap/rules.tsv'
```

## Best Practices

1. Run in staging, not production
2. Use authentication for full coverage
3. Exclude logout/destructive endpoints
4. Set reasonable timeouts
5. Review and triage findings
