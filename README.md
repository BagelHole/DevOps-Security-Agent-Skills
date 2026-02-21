<div align="center">

# 🛡️ DevOps & Security Agent Skills

### Your AI-Powered Second Brain for Infrastructure & Security

*Stop Googling. Start Shipping.*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Agent Skills](https://img.shields.io/badge/Format-Agent%20Skills-blueviolet.svg)](https://agentskills.io)

<br />

**[Explore Skills](#skill-catalog)** · **[Get Started](#quick-start)** · **[Contribute](CONTRIBUTING.md)**

<br />

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/kubernetes/kubernetes-plain.svg" width="40" />&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original.svg" width="40" />&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/terraform/terraform-original.svg" width="40" />&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/amazonwebservices/amazonwebservices-original-wordmark.svg" width="40" />&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/azure/azure-original.svg" width="40" />&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/googlecloud/googlecloud-original.svg" width="40" />&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/linux/linux-original.svg" width="40" />&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/prometheus/prometheus-original.svg" width="40" />

</div>

---

## 💡 The Problem

You're a **solo founder**, **indie hacker**, or **one-person DevOps team**. You need to:

- Set up CI/CD pipelines across 5 different platforms
- Harden your Linux servers (but you forgot the sysctl parameters)
- Write that Terraform module for the 47th time
- Remember how CloudTrail works... again
- Configure Kubernetes security contexts properly
- Actually understand what SOC2 needs

**You can't remember everything. You shouldn't have to.**

---

## 🚀 The Solution

This repo is a **comprehensive knowledge base** designed to be loaded into AI agents. It's your **DevOps second brain** — battle-tested scripts, production-ready configs, and expert knowledge organized using the [Agent Skills](https://agentskills.io) format:

| Domain | What You Get |
|--------|--------------|
| 🔧 **DevOps** | CI/CD, containers, K8s, observability, release management |
| 🔒 **Security** | Scanning, secrets, hardening, network security, incident response |
| ☁️ **Infrastructure** | AWS, Azure, GCP, servers, networking, databases, storage |
| 🤖 **AI & Platforms** | Agent infrastructure, local LLM ops, and modern app platforms |
| 📋 **Compliance** | SOC2, HIPAA, GDPR, PCI-DSS, governance, auditing |

---

## ✨ What's Inside

This isn't just documentation. Each skill includes:

```
skill/
├── SKILL.md          # AI-readable instructions & knowledge
├── scripts/          # Ready-to-run automation scripts
├── references/       # Deep-dive guides & cheatsheets  
└── assets/           # Config templates & examples
```

### 🎯 Real Examples

**Need to debug a crashing pod?**
```bash
./devops/orchestration/kubernetes-ops/scripts/pod-debug.sh my-pod
```

**Hardening a fresh Linux server?**
```bash
./security/hardening/linux-hardening/scripts/harden-system.sh --apply
```

**Setting up Vault from scratch?**
```bash
./security/secrets/hashicorp-vault/scripts/vault-init.sh
```

**Collecting evidence during an incident?**
```bash
./security/operations/incident-response/scripts/collect-evidence.sh INC-2024-001
```

---

## 🧠 How It Works

[Agent Skills](https://agentskills.io) is an open format for extending AI agent capabilities. Here's the flow:

```
┌─────────────────────────────────────────────────────────────────┐
│  1. DISCOVER        2. MATCH           3. ACTIVATE              │
│                                                                 │
│  Agent scans     →  User asks about  →  Agent reads full       │
│  skill folders      Kubernetes          SKILL.md + runs        │
│  at startup         debugging           scripts as needed      │
└─────────────────────────────────────────────────────────────────┘
```

Each `SKILL.md` has YAML frontmatter (name + description) that agents load at startup for matching, and markdown instructions that get loaded only when the skill is activated. This keeps context usage efficient.

📖 **Full spec:** [agentskills.io/specification](https://agentskills.io/specification)

---

## 🏃 Quick Start

### 1. Download the Skills

```bash
# Clone to your skills directory
git clone https://github.com/bagelhole/DevOps-Security-Agent-Skills.git ~/.skills/devops-security

# Or add as a submodule to your project
git submodule add https://github.com/bagelhole/DevOps-Security-Agent-Skills.git .skills/devops-security
```

### 2. Integrate with Your Agent

**Filesystem-based agents** (Cursor, Claude with computer use, Cline, etc.) are the easiest — the agent can read skills directly:

```bash
# Agent reads skill when needed
cat ~/.skills/devops-security/devops/orchestration/kubernetes-ops/SKILL.md
```

**Tool-based agents** need skills injected into the system prompt. Use the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) CLI:

```bash
# Generate XML for your agent's system prompt
skills-ref to-prompt ~/.skills/devops-security/devops/ci-cd/*

# Output:
# <available_skills>
#   <skill>
#     <name>github-actions</name>
#     <description>Build, test, and deploy with GitHub Actions workflows...</description>
#     <location>~/.skills/devops-security/devops/ci-cd/github-actions/SKILL.md</location>
#   </skill>
#   ...
# </available_skills>
```

### 3. Validate Skills (Optional)

```bash
# Check skill format is correct
skills-ref validate ~/.skills/devops-security/security/secrets/hashicorp-vault
```

### For Humans

No agent? No problem. Browse the skills, copy the scripts, use the configs. It's MIT licensed — go wild.

---

## 📚 Skill Catalog

<details>
<summary><b>🔧 DevOps</b></summary>

### CI/CD
| Skill | Description |
|-------|-------------|
| [github-actions](devops/ci-cd/github-actions/) | Build, test, and deploy with GitHub Actions |
| [gitlab-ci](devops/ci-cd/gitlab-ci/) | GitLab CI/CD pipelines and runners |
| [jenkins](devops/ci-cd/jenkins/) | Jenkins pipelines and shared libraries |
| [azure-devops](devops/ci-cd/azure-devops/) | Azure Pipelines and release management |
| [circleci](devops/ci-cd/circleci/) | CircleCI workflows and orbs |

### Containers
| Skill | Description |
|-------|-------------|
| [docker-management](devops/containers/docker-management/) | Docker images, multi-stage builds, optimization |
| [docker-compose](devops/containers/docker-compose/) | Multi-container applications |
| [podman](devops/containers/podman/) | Rootless container management |
| [container-registries](devops/containers/container-registries/) | ECR, ACR, GCR, Docker Hub |

### Orchestration
| Skill | Description |
|-------|-------------|
| [kubernetes-ops](devops/orchestration/kubernetes-ops/) | Deploy, scale, troubleshoot K8s |
| [helm-charts](devops/orchestration/helm-charts/) | Helm chart development and deployment |
| [argocd-gitops](devops/orchestration/argocd-gitops/) | GitOps with ArgoCD |
| [kustomize](devops/orchestration/kustomize/) | Kubernetes manifest customization |
| [openshift](devops/orchestration/openshift/) | OpenShift cluster management |

### Observability
| Skill | Description |
|-------|-------------|
| [prometheus-grafana](devops/observability/prometheus-grafana/) | Metrics and dashboards |
| [elk-stack](devops/observability/elk-stack/) | Elasticsearch, Logstash, Kibana |
| [loki-logging](devops/observability/loki-logging/) | Grafana Loki log aggregation |
| [datadog](devops/observability/datadog/) | Datadog monitoring and APM |
| [new-relic](devops/observability/new-relic/) | New Relic observability |
| [alerting-oncall](devops/observability/alerting-oncall/) | Alert rules and on-call rotations |

### AI Engineering
| Skill | Description |
|-------|-------------|
| [agent-observability](devops/ai/agent-observability/) | Tracing, latency, token, and cost telemetry for agents |
| [agent-evals](devops/ai/agent-evals/) | Automated regression and safety eval suites for agents |

### Release Management
| Skill | Description |
|-------|-------------|
| [git-workflow](devops/release/git-workflow/) | Branching strategies and PR workflows |
| [semantic-versioning](devops/release/semantic-versioning/) | Automated versioning and changelogs |
| [feature-flags](devops/release/feature-flags/) | LaunchDarkly, Unleash |
| [blue-green-deploy](devops/release/blue-green-deploy/) | Zero-downtime deployments |

</details>

<details>
<summary><b>🔒 Security</b></summary>

### Scanning
| Skill | Description |
|-------|-------------|
| [vulnerability-scanning](security/scanning/vulnerability-scanning/) | CVE scanning with Trivy, Grype |
| [sast-scanning](security/scanning/sast-scanning/) | Semgrep, CodeQL, SonarQube |
| [dast-scanning](security/scanning/dast-scanning/) | OWASP ZAP, Nuclei |
| [dependency-scanning](security/scanning/dependency-scanning/) | Snyk, Dependabot |
| [container-scanning](security/scanning/container-scanning/) | Image vulnerability scanning |

### Secrets Management
| Skill | Description |
|-------|-------------|
| [hashicorp-vault](security/secrets/hashicorp-vault/) | Vault setup, policies, secrets engines |
| [aws-secrets-manager](security/secrets/aws-secrets-manager/) | AWS secrets and rotation |
| [azure-keyvault](security/secrets/azure-keyvault/) | Azure Key Vault |
| [gcp-secret-manager](security/secrets/gcp-secret-manager/) | GCP Secret Manager |
| [sops-encryption](security/secrets/sops-encryption/) | Mozilla SOPS |

### Hardening
| Skill | Description |
|-------|-------------|
| [linux-hardening](security/hardening/linux-hardening/) | CIS benchmarks, sysctl, SSH |
| [windows-hardening](security/hardening/windows-hardening/) | Windows security baselines |
| [container-hardening](security/hardening/container-hardening/) | Secure Docker/K8s configs |
| [kubernetes-hardening](security/hardening/kubernetes-hardening/) | K8s security contexts and policies |
| [cis-benchmarks](security/hardening/cis-benchmarks/) | CIS benchmark auditing |

### Network Security
| Skill | Description |
|-------|-------------|
| [firewall-config](security/network/firewall-config/) | iptables, UFW, cloud firewalls |
| [waf-setup](security/network/waf-setup/) | AWS WAF, Cloudflare WAF |
| [zero-trust](security/network/zero-trust/) | Zero-trust architecture |
| [vpn-setup](security/network/vpn-setup/) | WireGuard, OpenVPN |
| [ssl-tls-management](security/network/ssl-tls-management/) | Let's Encrypt, certificate management |

### Security Operations
| Skill | Description |
|-------|-------------|
| [incident-response](security/operations/incident-response/) | IR playbooks and evidence collection |
| [threat-modeling](security/operations/threat-modeling/) | STRIDE methodology |
| [penetration-testing](security/operations/penetration-testing/) | Basic pentesting |
| [security-automation](security/operations/security-automation/) | Security workflow automation |

### AI Security
| Skill | Description |
|-------|-------------|
| [ai-agent-security](security/ai/ai-agent-security/) | Defend agents against injection, tool abuse, and exfiltration |
| [llm-app-security](security/ai/llm-app-security/) | Harden LLM app inputs, outputs, and tenant isolation |

</details>

<details>
<summary><b>☁️ Infrastructure</b></summary>

### AWS
| Skill | Description |
|-------|-------------|
| [terraform-aws](infrastructure/cloud-aws/terraform-aws/) | AWS infrastructure as code |
| [cloudformation](infrastructure/cloud-aws/cloudformation/) | CloudFormation templates |
| [aws-ec2](infrastructure/cloud-aws/aws-ec2/) | EC2 instances and AMIs |
| [aws-ecs-fargate](infrastructure/cloud-aws/aws-ecs-fargate/) | Container orchestration |
| [aws-lambda](infrastructure/cloud-aws/aws-lambda/) | Serverless functions |
| [aws-rds](infrastructure/cloud-aws/aws-rds/) | Managed databases |
| [aws-s3](infrastructure/cloud-aws/aws-s3/) | Object storage |
| [aws-vpc](infrastructure/cloud-aws/aws-vpc/) | Networking |
| [aws-iam](infrastructure/cloud-aws/aws-iam/) | Identity and access |

### Cloudflare
| Skill | Description |
|-------|-------------|
| [cloudflare-workers](infrastructure/cloudflare/cloudflare-workers/) | Edge functions and APIs with Wrangler |
| [cloudflare-pages](infrastructure/cloudflare/cloudflare-pages/) | Static/full-stack deployments with previews |
| [cloudflare-r2](infrastructure/cloudflare/cloudflare-r2/) | S3-compatible object storage without egress fees |
| [cloudflare-zero-trust](infrastructure/cloudflare/cloudflare-zero-trust/) | Access policies and private app protection |

### Azure
| Skill | Description |
|-------|-------------|
| [terraform-azure](infrastructure/cloud-azure/terraform-azure/) | Azure infrastructure as code |
| [arm-templates](infrastructure/cloud-azure/arm-templates/) | ARM/Bicep templates |
| [azure-vms](infrastructure/cloud-azure/azure-vms/) | Virtual machines |
| [azure-functions](infrastructure/cloud-azure/azure-functions/) | Serverless |
| [azure-aks](infrastructure/cloud-azure/azure-aks/) | Kubernetes |
| [azure-sql](infrastructure/cloud-azure/azure-sql/) | Databases |
| [azure-networking](infrastructure/cloud-azure/azure-networking/) | VNets and NSGs |

### GCP
| Skill | Description |
|-------|-------------|
| [terraform-gcp](infrastructure/cloud-gcp/terraform-gcp/) | GCP infrastructure as code |
| [gcp-compute](infrastructure/cloud-gcp/gcp-compute/) | Compute Engine |
| [gcp-cloud-functions](infrastructure/cloud-gcp/gcp-cloud-functions/) | Serverless |
| [gcp-gke](infrastructure/cloud-gcp/gcp-gke/) | Kubernetes |
| [gcp-cloud-sql](infrastructure/cloud-gcp/gcp-cloud-sql/) | Databases |
| [gcp-networking](infrastructure/cloud-gcp/gcp-networking/) | VPCs and firewall |

### Server Management
| Skill | Description |
|-------|-------------|
| [linux-administration](infrastructure/servers/linux-administration/) | Core Linux admin |
| [windows-server](infrastructure/servers/windows-server/) | Windows administration |
| [ssh-configuration](infrastructure/servers/ssh-configuration/) | SSH and bastion hosts |
| [user-management](infrastructure/servers/user-management/) | Users, groups, sudo |
| [systemd-services](infrastructure/servers/systemd-services/) | Services and timers |
| [performance-tuning](infrastructure/servers/performance-tuning/) | System optimization |

### Networking
| Skill | Description |
|-------|-------------|
| [dns-management](infrastructure/networking/dns-management/) | DNS and Route53 |
| [load-balancing](infrastructure/networking/load-balancing/) | ALB, nginx, HAProxy |
| [cdn-setup](infrastructure/networking/cdn-setup/) | CloudFront, Cloudflare |
| [reverse-proxy](infrastructure/networking/reverse-proxy/) | nginx, Traefik |
| [service-mesh](infrastructure/networking/service-mesh/) | Istio, Linkerd |

### Databases
| Skill | Description |
|-------|-------------|
| [postgresql](infrastructure/databases/postgresql/) | PostgreSQL admin |
| [mysql](infrastructure/databases/mysql/) | MySQL/MariaDB |
| [planetscale](infrastructure/databases/planetscale/) | Branch-based MySQL schema deployments |
| [mongodb](infrastructure/databases/mongodb/) | MongoDB clusters |
| [redis](infrastructure/databases/redis/) | Redis caching |
| [database-backups](infrastructure/databases/database-backups/) | Backup strategies |

### Storage
| Skill | Description |
|-------|-------------|
| [block-storage](infrastructure/storage/block-storage/) | EBS, LVM |
| [object-storage](infrastructure/storage/object-storage/) | S3, MinIO |
| [nfs-storage](infrastructure/storage/nfs-storage/) | NFS servers |
| [backup-recovery](infrastructure/storage/backup-recovery/) | Backup with restic |

### Platforms
| Skill | Description |
|-------|-------------|
| [vercel-deployments](infrastructure/platforms/vercel-deployments/) | Preview and production web app deployments |
| [convex-backend](infrastructure/platforms/convex-backend/) | Realtime managed backend with typed functions |
| [firebase-app-platform](infrastructure/platforms/firebase-app-platform/) | Firebase auth, data, functions, and hosting |

### Local AI Infrastructure
| Skill | Description |
|-------|-------------|
| [ollama-stack](infrastructure/local-ai/ollama-stack/) | Private local inference stack with Ollama |
| [mac-mini-llm-lab](infrastructure/local-ai/mac-mini-llm-lab/) | Mac mini setup for always-on local LLM serving |
| [openclaw-local-mac-mini](infrastructure/local-ai/openclaw-local-mac-mini/) | OpenClaw setup for local development and Mac mini hosting |

### IT Operations
| Skill | Description |
|-------|-------------|
| [startup-it-troubleshooting](infrastructure/it/startup-it-troubleshooting/) | Practical IT troubleshooting for small teams |

</details>

<details>
<summary><b>📋 Compliance</b></summary>

### Frameworks
| Skill | Description |
|-------|-------------|
| [soc2-compliance](compliance/frameworks/soc2-compliance/) | SOC2 Trust Services Criteria |
| [hipaa-compliance](compliance/frameworks/hipaa-compliance/) | HIPAA security rules |
| [gdpr-compliance](compliance/frameworks/gdpr-compliance/) | GDPR data protection |
| [pci-dss-compliance](compliance/frameworks/pci-dss-compliance/) | PCI-DSS requirements |
| [iso27001-compliance](compliance/frameworks/iso27001-compliance/) | ISO 27001 ISMS |
| [fedramp-compliance](compliance/frameworks/fedramp-compliance/) | FedRAMP controls |

### Governance
| Skill | Description |
|-------|-------------|
| [policy-as-code](compliance/governance/policy-as-code/) | OPA, Kyverno, Checkov |
| [access-review](compliance/governance/access-review/) | IAM access reviews |
| [change-management](compliance/governance/change-management/) | Change control |
| [asset-inventory](compliance/governance/asset-inventory/) | Asset tracking |
| [vendor-management](compliance/governance/vendor-management/) | Third-party security |

### Auditing
| Skill | Description |
|-------|-------------|
| [audit-logging](compliance/auditing/audit-logging/) | Centralized audit logs |
| [aws-cloudtrail](compliance/auditing/aws-cloudtrail/) | CloudTrail configuration |
| [azure-monitor-audit](compliance/auditing/azure-monitor-audit/) | Azure Monitor logs |
| [gcp-audit-logs](compliance/auditing/gcp-audit-logs/) | GCP Cloud Audit Logs |

### Business Continuity
| Skill | Description |
|-------|-------------|
| [disaster-recovery](compliance/continuity/disaster-recovery/) | DR strategies |
| [business-continuity](compliance/continuity/business-continuity/) | BCP planning |
| [incident-management](compliance/continuity/incident-management/) | Incident processes |
| [runbook-creation](compliance/continuity/runbook-creation/) | Operational runbooks |

</details>

---

## 🤝 Contributing

Found a bug? Want to add a skill? PRs are welcome!

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## ⭐ Support

If this helped you ship faster, **star this repo** — it helps others find it too.

Built with ☕ by [Toby Miller](https://github.com/bagelhole)

---

<div align="center">

**[⬆ Back to Top](#-devops--security-agent-skills)**

</div>
