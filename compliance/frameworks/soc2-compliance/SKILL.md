---
name: soc2-compliance
description: "Implement SOC 2 Trust Services Criteria for Type I and Type II audits. Perform gap analysis, generate control policies, map controls to AICPA criteria, and automate audit evidence collection. Use when preparing for SOC 2 certification, compliance audits, configuring security and availability controls, or automating evidence gathering for auditor requests."
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# SOC 2 Compliance

Implement SOC 2 Trust Services Criteria controls, evidence collection, and continuous compliance monitoring for Type I and Type II audits.

## Implementation Workflow

1. **Gap assessment**: Identify which TSC criteria (CC1–CC9, A1, PI1, C1, P1–P8) have existing controls vs. gaps. Prioritize CC6 (logical access) and CC7 (system operations) — auditors focus here first.
2. **Control mapping**: For each criteria, map to a specific tool, owner, and evidence artifact. Verify mappings produce actual evidence by running a test collection.
3. **Evidence automation**: Deploy the collection script below on a monthly schedule. After each run, verify outputs are non-empty and contain expected data.
4. **Continuous monitoring**: Set up the GitHub Actions workflow to catch drift between audit periods. Review alerts weekly.
5. **Audit prep**: Follow the timeline below, starting 12 months before the target audit date. For Type I, focus on control design; for Type II, ensure controls operated effectively over the observation period.

## Evidence Collection Automation

```bash
#!/usr/bin/env bash
# collect-soc2-evidence.sh - Automated SOC 2 evidence collection
# Run monthly or before audit requests

EVIDENCE_DIR="./soc2-evidence/$(date +%Y-%m)"
mkdir -p "$EVIDENCE_DIR"

echo "=== CC6.1 - Logical Access Evidence ==="

# AWS IAM credential report
aws iam generate-credential-report
sleep 10
aws iam get-credential-report --output text --query Content | \
  base64 -d > "$EVIDENCE_DIR/aws-iam-credential-report.csv"

# AWS IAM Access Analyzer findings
aws accessanalyzer list-findings \
  --analyzer-arn "arn:aws:access-analyzer:us-east-1:123456789012:analyzer/org-analyzer" \
  --filter '{"status": {"eq": ["ACTIVE"]}}' \
  > "$EVIDENCE_DIR/access-analyzer-findings.json"

# MFA enforcement status
aws iam list-users --query 'Users[*].UserName' --output text | \
  tr '\t' '\n' | while read -r user; do
    mfa=$(aws iam list-mfa-devices --user-name "$user" --query 'MFADevices[0].SerialNumber' --output text)
    echo "$user,$mfa"
  done > "$EVIDENCE_DIR/mfa-status.csv"

# GitHub organization members and roles
gh api orgs/YOUR_ORG/members --paginate --jq '.[] | [.login, .role_name // "member"] | @csv' \
  > "$EVIDENCE_DIR/github-org-members.csv"

# GitHub branch protection rules
for repo in $(gh repo list YOUR_ORG --json name -q '.[].name'); do
  gh api repos/YOUR_ORG/$repo/branches/main/protection \
    > "$EVIDENCE_DIR/branch-protection-$repo.json" 2>/dev/null
done

echo "=== CC7.2 - Monitoring Evidence ==="

# CloudTrail status
aws cloudtrail get-trail-status --name org-audit-trail \
  > "$EVIDENCE_DIR/cloudtrail-status.json"

# Active CloudWatch alarms
aws cloudwatch describe-alarms --state-value ALARM \
  > "$EVIDENCE_DIR/active-alarms.json"

# GuardDuty findings summary
aws guardduty list-findings --detector-id DETECTOR_ID \
  --finding-criteria '{"criterion":{"severity":{"gte":4}}}' \
  > "$EVIDENCE_DIR/guardduty-findings.json"

echo "=== CC8.1 - Change Management Evidence ==="

# Recent deployments (GitHub Actions)
gh run list --repo YOUR_ORG/YOUR_REPO --limit 50 --json conclusion,createdAt,displayTitle,headBranch \
  > "$EVIDENCE_DIR/recent-deployments.json"

# Pull requests merged in audit period
gh pr list --repo YOUR_ORG/YOUR_REPO --state merged --limit 100 \
  --json number,title,author,mergedBy,mergedAt,reviews \
  > "$EVIDENCE_DIR/merged-prs.json"

echo "=== A1 - Availability Evidence ==="

# Backup status
aws rds describe-db-snapshots --db-instance-identifier prod-db \
  --query 'DBSnapshots | sort_by(@, &SnapshotCreateTime) | [-5:]' \
  > "$EVIDENCE_DIR/rds-backup-snapshots.json"

# S3 replication status
aws s3api get-bucket-replication --bucket prod-data-bucket \
  > "$EVIDENCE_DIR/s3-replication-config.json"

echo "Evidence collected in $EVIDENCE_DIR"
tar -czf "$EVIDENCE_DIR.tar.gz" "$EVIDENCE_DIR"
echo "Archive: $EVIDENCE_DIR.tar.gz"
```

## Audit Preparation Timeline

```yaml
audit_prep_timeline:
  12_months_before:
    - Select auditor firm and sign engagement letter
    - Perform gap assessment against TSC criteria
    - Remediate identified control gaps
    - Begin formal evidence collection cadence

  6_months_before:
    - Conduct internal readiness assessment
    - Verify all controls are operating effectively
    - Complete risk assessment and update risk register
    - Ensure vendor assessments are current
    - Test disaster recovery procedures

  3_months_before:
    - Run automated evidence collection and verify completeness
    - Conduct access review and remediate findings
    - Review and update all policies and procedures
    - Perform vulnerability scan and penetration test
    - Confirm all training records are current

  1_month_before:
    - Prepare evidence request list responses
    - Organize evidence into auditor-friendly structure
    - Brief key personnel on audit interviews
    - Verify monitoring dashboards show healthy state
    - Confirm incident response records are complete

  during_audit:
    - Designate audit liaison for request management
    - Provide timely evidence and clarifications
    - Track open auditor questions
    - Escalate issues to control owners promptly

  after_audit:
    - Review draft report and provide management response
    - Create remediation plan for any exceptions
    - Communicate results to stakeholders
    - Update controls and processes based on findings
    - Begin next audit period evidence collection
```

## Continuous Compliance Monitoring

```yaml
# GitHub Actions workflow for continuous SOC 2 checks
name: SOC2 Compliance Checks
on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  access-review:
    runs-on: ubuntu-latest
    steps:
      - name: Check MFA enforcement
        run: |
          USERS_WITHOUT_MFA=$(aws iam generate-credential-report && sleep 5 && \
            aws iam get-credential-report --output text --query Content | \
            base64 -d | awk -F, '$4=="true" && $8=="false" {print $1}')
          if [ -n "$USERS_WITHOUT_MFA" ]; then
            echo "::error::Users without MFA: $USERS_WITHOUT_MFA"
            exit 1
          fi

      - name: Check for unused credentials
        run: |
          THRESHOLD=$(date -d '90 days ago' +%Y-%m-%dT%H:%M:%S)
          aws iam get-credential-report --output text --query Content | \
            base64 -d | awk -F, -v t="$THRESHOLD" '$5!="N/A" && $5<t {print $1" last used "$5}'

      - name: Verify CloudTrail is logging
        run: |
          STATUS=$(aws cloudtrail get-trail-status --name org-audit-trail --query 'IsLogging' --output text)
          [ "$STATUS" = "True" ] || (echo "::error::CloudTrail logging stopped" && exit 1)

      - name: Check GuardDuty is enabled
        run: |
          DETECTOR=$(aws guardduty list-detectors --query 'DetectorIds[0]' --output text)
          [ "$DETECTOR" != "None" ] || (echo "::error::GuardDuty not enabled" && exit 1)
```

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Evidence gaps for CC6.1 | IAM credential report not generated regularly | Schedule `aws iam generate-credential-report` monthly; verify CSV is non-empty |
| Audit finding on CC8.1 | PRs merged without required approvals | Enforce branch protection rules requiring 1+ approvals and CI checks |
| Type II observation period too short | Started evidence collection late | Begin formal collection 12 months before target audit date |
| Monitoring gaps for CC7 | Alerts configured but not reviewed | Add weekly alert triage to on-call rotation; track in ticketing system |
