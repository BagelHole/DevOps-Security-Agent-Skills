---
name: policy-as-code
description: Implement policy as code with OPA, Sentinel, and Kyverno. Automate policy enforcement in CI/CD and infrastructure. Use when enforcing compliance through automation.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Policy as Code

Automate policy enforcement through code.

## Open Policy Agent (OPA)

```rego
# deny_public_buckets.rego
package terraform.s3

deny[msg] {
    resource := input.resource.aws_s3_bucket[name]
    resource.acl == "public-read"
    msg := sprintf("S3 bucket '%s' has public ACL", [name])
}
```

## Kyverno (Kubernetes)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: enforce
  rules:
  - name: check-labels
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Label 'app' is required"
      pattern:
        metadata:
          labels:
            app: "?*"
```

## Checkov

```bash
# Scan Terraform
checkov -d . --framework terraform

# Custom check
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class S3Encryption(BaseResourceCheck):
    def scan_resource_conf(self, conf):
        return CheckResult.PASSED if 'encryption' in conf else CheckResult.FAILED
```

## Best Practices

- Version control policies
- Test policies in CI
- Gradual rollout (warn → enforce)
- Exception management
