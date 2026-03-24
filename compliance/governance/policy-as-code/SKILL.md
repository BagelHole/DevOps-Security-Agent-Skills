---
name: policy-as-code
description: Implement policy as code with OPA, Sentinel, and Kyverno. Automate policy enforcement in CI/CD and infrastructure. Use when enforcing compliance through automation.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Policy as Code

Automate policy enforcement through code using OPA/Rego, Kyverno, Checkov, and CI/CD integration to prevent compliance violations before they reach production.

## When to Use

- Enforcing security and compliance policies on infrastructure-as-code changes
- Preventing misconfigured Kubernetes workloads from deploying
- Automating guardrails in CI/CD pipelines for Terraform, CloudFormation, or Helm
- Implementing organizational standards that must be consistently applied
- Replacing manual approval gates with automated policy checks

## Open Policy Agent (OPA) Rego Policies

```rego
# deny_public_s3.rego - Deny S3 buckets with public access
package terraform.aws.s3

import rego.v1

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.after.acl == "public-read"
    msg := sprintf(
        "S3 bucket '%s' has public-read ACL. All buckets must be private. [Policy: no-public-s3]",
        [resource.address]
    )
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.after.acl == "public-read-write"
    msg := sprintf(
        "S3 bucket '%s' has public-read-write ACL. This is strictly prohibited. [Policy: no-public-s3]",
        [resource.address]
    )
}
```

```rego
# require_encryption.rego - Require encryption on data stores
package terraform.aws.encryption

import rego.v1

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    not resource.change.after.storage_encrypted
    msg := sprintf(
        "RDS instance '%s' does not have storage encryption enabled. [Policy: require-rds-encryption]",
        [resource.address]
    )
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_ebs_volume"
    not resource.change.after.encrypted
    msg := sprintf(
        "EBS volume '%s' is not encrypted. [Policy: require-ebs-encryption]",
        [resource.address]
    )
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not has_encryption(resource)
    msg := sprintf(
        "S3 bucket '%s' does not have default encryption configured. [Policy: require-s3-encryption]",
        [resource.address]
    )
}

has_encryption(resource) if {
    resource.change.after.server_side_encryption_configuration[_]
}
```

```rego
# require_tags.rego - Enforce mandatory tagging
package terraform.aws.tags

import rego.v1

required_tags := {"Environment", "Owner", "CostCenter", "DataClassification"}

deny contains msg if {
    resource := input.resource_changes[_]
    tags := object.get(resource.change.after, "tags", {})
    missing := required_tags - {key | tags[key]}
    count(missing) > 0
    msg := sprintf(
        "Resource '%s' is missing required tags: %v. [Policy: required-tags]",
        [resource.address, missing]
    )
}
```

```rego
# restrict_regions.rego - Limit resource deployment to approved regions
package terraform.aws.regions

import rego.v1

approved_regions := {"us-east-1", "us-west-2", "eu-west-1"}

deny contains msg if {
    resource := input.resource_changes[_]
    provider_config := input.configuration.provider_config.aws
    region := provider_config.expressions.region.constant_value
    not region in approved_regions
    msg := sprintf(
        "Resource '%s' is in region '%s'. Approved regions: %v. [Policy: approved-regions]",
        [resource.address, region, approved_regions]
    )
}
```

```bash
# Evaluate OPA policies against Terraform plan
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Run OPA evaluation
opa eval \
  --data policies/ \
  --input tfplan.json \
  "data.terraform.aws.s3.deny" \
  --format pretty

# Use conftest for easier CI integration
conftest test tfplan.json --policy policies/ --output table
```

## Kyverno Kubernetes Policies

```yaml
# require-labels.yaml - Enforce required labels on all pods
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
  annotations:
    policies.kyverno.io/title: Require Labels
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/severity: medium
spec:
  validationFailureAction: Enforce
  background: true
  rules:
  - name: check-required-labels
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: >-
        Labels 'app.kubernetes.io/name', 'app.kubernetes.io/version',
        and 'team' are required on all Pods.
      pattern:
        metadata:
          labels:
            app.kubernetes.io/name: "?*"
            app.kubernetes.io/version: "?*"
            team: "?*"
---
# disallow-privileged.yaml - Block privileged containers
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged-containers
  annotations:
    policies.kyverno.io/title: Disallow Privileged Containers
    policies.kyverno.io/category: Pod Security
    policies.kyverno.io/severity: high
spec:
  validationFailureAction: Enforce
  background: true
  rules:
  - name: deny-privileged
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Privileged containers are not allowed."
      pattern:
        spec:
          containers:
          - securityContext:
              privileged: "false"
          =(initContainers):
          - securityContext:
              privileged: "false"
---
# require-resource-limits.yaml - Enforce resource limits
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-resource-limits
  annotations:
    policies.kyverno.io/title: Require Resource Limits
    policies.kyverno.io/severity: medium
spec:
  validationFailureAction: Enforce
  background: true
  rules:
  - name: check-resource-limits
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "All containers must have CPU and memory limits defined."
      pattern:
        spec:
          containers:
          - resources:
              limits:
                memory: "?*"
                cpu: "?*"
---
# disallow-latest-tag.yaml - Block usage of 'latest' image tag
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
  annotations:
    policies.kyverno.io/title: Disallow Latest Tag
    policies.kyverno.io/severity: medium
spec:
  validationFailureAction: Enforce
  background: true
  rules:
  - name: validate-image-tag
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Images must use a specific tag, not 'latest'."
      pattern:
        spec:
          containers:
          - image: "!*:latest & *:*"
---
# restrict-image-registries.yaml - Allow only approved registries
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-image-registries
  annotations:
    policies.kyverno.io/title: Restrict Image Registries
    policies.kyverno.io/severity: high
spec:
  validationFailureAction: Enforce
  background: true
  rules:
  - name: validate-registries
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: >-
        Images must come from approved registries:
        123456789012.dkr.ecr.us-east-1.amazonaws.com or ghcr.io/your-org.
      pattern:
        spec:
          containers:
          - image: "123456789012.dkr.ecr.*.amazonaws.com/* | ghcr.io/your-org/*"
---
# require-networkpolicy.yaml - Ensure namespaces have NetworkPolicies
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-networkpolicy
  annotations:
    policies.kyverno.io/title: Require Network Policy
    policies.kyverno.io/severity: high
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: check-networkpolicy
    match:
      any:
      - resources:
          kinds:
          - Deployment
    preconditions:
      all:
      - key: "{{request.object.metadata.namespace}}"
        operator: NotIn
        value: ["kube-system", "kube-public"]
    validate:
      message: "A NetworkPolicy must exist in namespace '{{request.object.metadata.namespace}}' before deploying workloads."
      deny:
        conditions:
          all:
          - key: "{{request.object.metadata.namespace}}"
            operator: AnyNotIn
            value: "{{request.object.metadata.namespace}}"
```

## Checkov Custom Checks

```python
# custom_checks/require_s3_versioning.py
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckResult, CheckCategories


class S3Versioning(BaseResourceCheck):
    def __init__(self):
        name = "Ensure S3 bucket has versioning enabled"
        id = "CUSTOM_S3_001"
        supported_resources = ["aws_s3_bucket_versioning"]
        categories = [CheckCategories.BACKUP_AND_RECOVERY]
        super().__init__(name=name, id=id,
                         categories=categories,
                         supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        versioning = conf.get("versioning_configuration", [{}])
        if isinstance(versioning, list):
            versioning = versioning[0] if versioning else {}
        status = versioning.get("status", ["Disabled"])
        if isinstance(status, list):
            status = status[0]
        return CheckResult.PASSED if status == "Enabled" else CheckResult.FAILED


check = S3Versioning()
```

```python
# custom_checks/require_rds_backup.py
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckResult, CheckCategories


class RDSBackupRetention(BaseResourceCheck):
    def __init__(self):
        name = "Ensure RDS has backup retention of at least 7 days"
        id = "CUSTOM_RDS_001"
        supported_resources = ["aws_db_instance"]
        categories = [CheckCategories.BACKUP_AND_RECOVERY]
        super().__init__(name=name, id=id,
                         categories=categories,
                         supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        retention = conf.get("backup_retention_period", [0])
        if isinstance(retention, list):
            retention = retention[0]
        return CheckResult.PASSED if int(retention) >= 7 else CheckResult.FAILED


check = RDSBackupRetention()
```

```bash
# Run Checkov with custom checks
checkov -d ./terraform \
  --framework terraform \
  --external-checks-dir ./custom_checks \
  --output cli \
  --compact

# Run specific check IDs
checkov -d ./terraform \
  --check CUSTOM_S3_001,CUSTOM_RDS_001,CKV_AWS_18,CKV_AWS_19

# Generate SARIF output for GitHub Advanced Security integration
checkov -d ./terraform \
  --framework terraform \
  --output sarif \
  --output-file checkov-results.sarif

# Skip specific checks with documented justification
checkov -d ./terraform \
  --skip-check CKV_AWS_145 \
  --skip-check CKV_AWS_79
```

## CI/CD Pipeline Integration

```yaml
# GitHub Actions - Policy enforcement in PR workflow
name: Policy Checks
on:
  pull_request:
    paths:
      - 'terraform/**'
      - 'kubernetes/**'

jobs:
  terraform-policy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init and Plan
        working-directory: terraform/
        run: |
          terraform init -backend=false
          terraform plan -out=tfplan
          terraform show -json tfplan > tfplan.json

      - name: OPA Policy Check
        uses: open-policy-agent/setup-opa@v2
        with:
          version: latest
      - run: |
          RESULTS=$(opa eval \
            --data policies/ \
            --input terraform/tfplan.json \
            --format json \
            "data.terraform" | jq '.result[0].expressions[0].value')
          DENY_COUNT=$(echo "$RESULTS" | jq '[.. | .deny? // empty | .[] ] | length')
          if [ "$DENY_COUNT" -gt 0 ]; then
            echo "::error::Policy violations found:"
            echo "$RESULTS" | jq '.. | .deny? // empty | .[]'
            exit 1
          fi

      - name: Checkov Scan
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: terraform/
          framework: terraform
          output_format: cli,sarif
          output_file_path: console,checkov-results.sarif
          soft_fail: false
          external_checks_dirs: custom_checks/

      - name: Upload SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: checkov-results.sarif

  kubernetes-policy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Kyverno CLI
        run: |
          curl -LO https://github.com/kyverno/kyverno/releases/latest/download/kyverno-cli_linux_amd64.tar.gz
          tar -xzf kyverno-cli_linux_amd64.tar.gz
          sudo mv kyverno /usr/local/bin/

      - name: Test Kyverno Policies
        run: |
          kyverno apply policies/kyverno/ \
            --resource kubernetes/manifests/ \
            --detailed-results \
            --output-format table

      - name: Conftest Kubernetes Manifests
        uses: open-policy-agent/conftest-action@v2
        with:
          files: kubernetes/manifests/
          policy: policies/kubernetes/
```

## Policy Exception Management

```yaml
exception_workflow:
  request:
    fields:
      - policy_id: "Which policy needs an exception"
      - resource: "Specific resource requiring exception"
      - justification: "Business reason for the exception"
      - compensating_controls: "Alternative mitigations in place"
      - duration: "Temporary (with expiry) or permanent"
      - requestor: "Person requesting"
      - approver: "Security team member who approved"

  approval_process:
    1: "Requestor submits exception with justification"
    2: "Security team reviews and assesses risk"
    3: "Compensating controls verified"
    4: "Exception approved or denied with rationale"
    5: "Exception documented in registry"
    6: "Automated enforcement updated to allow exception"

  enforcement:
    opa: |
      # Exception list loaded as data
      # policies/exceptions.json
      # {"exceptions": [{"resource": "aws_s3_bucket.public_website", "policy": "no-public-s3", "expires": "2025-06-01"}]}
    kyverno: |
      # Use Kyverno PolicyException resource
      apiVersion: kyverno.io/v2beta1
      kind: PolicyException
      metadata:
        name: allow-public-website
        namespace: web
      spec:
        exceptions:
        - policyName: disallow-privileged-containers
          ruleNames:
          - deny-privileged
        match:
          any:
          - resources:
              kinds:
              - Pod
              names:
              - legacy-app-*

  review_schedule:
    - Review all active exceptions quarterly
    - Expire temporary exceptions automatically
    - Re-justify permanent exceptions annually
    - Track exception count trends as a security metric
```

## Policy Testing

```bash
# Test OPA policies with mock input
mkdir -p policies/tests

# Create test input
cat > policies/tests/public_bucket_test.json <<'EOF'
{
  "resource_changes": [{
    "address": "aws_s3_bucket.test",
    "type": "aws_s3_bucket",
    "change": {
      "after": {"acl": "public-read"}
    }
  }]
}
EOF

# Run test
opa eval --data policies/ --input policies/tests/public_bucket_test.json \
  "data.terraform.aws.s3.deny" --format pretty
# Should output the deny message

# OPA unit tests
cat > policies/tests/s3_test.rego <<'EOF'
package terraform.aws.s3_test

import rego.v1
import data.terraform.aws.s3

test_deny_public_bucket if {
    result := s3.deny with input as {"resource_changes": [{"address": "test", "type": "aws_s3_bucket", "change": {"after": {"acl": "public-read"}}}]}
    count(result) > 0
}

test_allow_private_bucket if {
    result := s3.deny with input as {"resource_changes": [{"address": "test", "type": "aws_s3_bucket", "change": {"after": {"acl": "private"}}}]}
    count(result) == 0
}
EOF

opa test policies/ -v
```

## Best Practices

- Version control all policies alongside the infrastructure code they govern
- Start in audit/warn mode and transition to enforce after verifying no false positives
- Write unit tests for every policy to catch regressions and verify intended behavior
- Implement a formal exception process: never disable policies to bypass legitimate checks
- Use policy results as PR status checks to block non-compliant merges
- Layer policies: Checkov for static analysis, OPA for Terraform plan evaluation, Kyverno for runtime
- Tag policies with compliance framework references (e.g., SOC 2 CC6.1, PCI Req 2.2)
- Monitor policy violation trends over time to identify systemic issues
- Provide clear, actionable error messages that explain how to fix violations
- Roll out new policies gradually: inform teams, give a remediation window, then enforce
