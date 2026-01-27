# SAST Tools Reference

## Tool Comparison

| Tool | Languages | License | CI Integration |
|------|-----------|---------|----------------|
| **Semgrep** | 30+ | LGPL/Commercial | Excellent |
| **SonarQube** | 30+ | LGPL/Commercial | Excellent |
| **CodeQL** | 10+ | MIT | GitHub native |
| **Bandit** | Python | Apache 2.0 | Good |
| **ESLint Security** | JavaScript | MIT | Good |
| **Brakeman** | Ruby | MIT | Good |

## Semgrep

```bash
# Install
pip install semgrep

# Scan with default rules
semgrep --config auto .

# Scan with specific ruleset
semgrep --config p/owasp-top-ten .
semgrep --config p/security-audit .

# Output JSON
semgrep --config auto --json -o results.json .
```

### Custom Rules
```yaml
rules:
  - id: sql-injection
    patterns:
      - pattern: |
          $QUERY = "..." + $INPUT + "..."
      - metavariable-regex:
          metavariable: $QUERY
          regex: (?i)(select|insert|update|delete)
    message: "Potential SQL injection"
    severity: ERROR
    languages: [python]
```

## SonarQube

```bash
# Scanner CLI
sonar-scanner \
  -Dsonar.projectKey=myproject \
  -Dsonar.sources=src \
  -Dsonar.host.url=http://sonarqube:9000 \
  -Dsonar.token=$SONAR_TOKEN
```

### Quality Gate
```yaml
# sonar-project.properties
sonar.projectKey=myproject
sonar.sources=src
sonar.tests=tests
sonar.coverage.exclusions=**/test/**
sonar.qualitygate.wait=true
```

## CodeQL

```yaml
# .github/workflows/codeql.yml
- uses: github/codeql-action/init@v2
  with:
    languages: javascript, python
    
- uses: github/codeql-action/analyze@v2
```

## Bandit (Python)

```bash
# Run scan
bandit -r ./src -f json -o bandit-report.json

# With severity filter
bandit -r ./src -ll  # Medium and above
```

## ESLint Security

```json
// .eslintrc
{
  "plugins": ["security"],
  "extends": ["plugin:security/recommended"]
}
```

## CI Integration

```yaml
# GitHub Actions
- name: Run Semgrep
  uses: returntocorp/semgrep-action@v1
  with:
    config: p/security-audit
```
