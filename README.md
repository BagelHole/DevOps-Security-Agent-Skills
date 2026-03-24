<div align="center">

# 🛡️ DevOps & Security Agent Skills

### Your AI-Powered Second Brain for Infrastructure & Security

*160+ production-ready skills for Claude Code, Cursor, Codex, and every AI agent that reads files.*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-160%2B-orange.svg)](#skill-catalog)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Agent Skills](https://img.shields.io/badge/Format-Agent%20Skills-blueviolet.svg)](https://agentskills.io)
[![skills.sh](https://img.shields.io/badge/skills.sh-cli-000000.svg)](https://skills.sh/docs)

<br />

**[Explore Skills](#-skill-catalog)** · **[Install in 30 Seconds](#-quick-start)** · **[Contribute](CONTRIBUTING.md)**

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

## Why This Exists

Install these skills and your agent gains expert-level knowledge of:

| Domain | Skills | What Your Agent Learns |
|--------|--------|----------------------|
| 🔧 **DevOps** | 40+ | CI/CD pipelines, K8s ops, observability, release strategies, platform engineering |
| 🔒 **Security** | 35+ | Vulnerability scanning, secrets management, hardening, AI agent security, MCP security |
| ☁️ **Infrastructure** | 65+ | AWS, Azure, GCP, Cloudflare, databases, networking, GPU clusters, local AI |
| 🤖 **AI Engineering** | 20+ | LLMOps, agent evals, RAG infrastructure, inference scaling, coding agent guardrails |
| 📋 **Compliance** | 20+ | SOC2, HIPAA, GDPR, PCI-DSS, policy-as-code, auditing |
| 💻 **IT Operations** | 5+ | Device management, identity/SSO, SaaS security, troubleshooting |

---

## 30-Second Install

```bash
# Install all skills to Claude Code, Cursor, Codex, or any supported agent
npx skills add bagelhole/DevOps-Security-Agent-Skills

# Install specific skills
npx skills add bagelhole/DevOps-Security-Agent-Skills --skill kubernetes-ops --skill hashicorp-vault -a cursor -y

# Or clone directly
git clone https://github.com/bagelhole/DevOps-Security-Agent-Skills.git ~/.skills/devops-security
```

Works with **Claude Code**, **Cursor**, **Codex**, **OpenCode**, **Cline**, and [many more](https://github.com/vercel-labs/skills#supported-agents).

---

## What Makes This Different

Most "awesome lists" give you links. This repo gives your AI agent **production-ready knowledge** it can act on:

```yaml
# Every skill includes real, copy-pasteable configs like this:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:1.0.0
        resources:
          requests: { memory: "128Mi", cpu: "100m" }
          limits: { memory: "256Mi", cpu: "500m" }
        securityContext:
          runAsNonRoot: true
          readOnlyRootFilesystem: true
```

### What's in Each Skill

```
skill/
├── SKILL.md          # 250-400+ lines of expert knowledge
│   ├── When to Use   # Decision guidance
│   ├── Prerequisites # What you need
│   ├── Real Configs  # Copy-pasteable YAML, JSON, HCL, Bash
│   ├── CLI Commands  # Exact commands to run
│   ├── Troubleshooting # Common issues + fixes
│   └── Related Skills  # Cross-references
├── scripts/          # Ready-to-run automation
├── references/       # Deep-dive guides
└── assets/           # Config templates
```

---

## Hot Topics (March 2026)

Skills you won't find in other repos:

| Skill | Why It's Hot |
|-------|-------------|
| [**MCP Server Security**](security/ai/mcp-server-security/) | MCP is everywhere — secure your tool servers |
| [**AI Coding Agent Guardrails**](security/ai/ai-coding-agent-guardrails/) | Safe Claude Code/Cursor/Codex usage for teams |
| [**eBPF Observability**](devops/observability/ebpf-observability/) | Kernel-level monitoring with Cilium & Tetragon |
| [**Platform Engineering**](devops/platforms/platform-engineering/) | Build internal developer platforms with Backstage |
| [**Supply Chain Attack Response**](security/scanning/supply-chain-attack-response/) | Detect & respond to compromised dependencies |
| [**OpenTofu Migration**](infrastructure/iac/opentofu-migration/) | Migrate from Terraform to the open-source fork |
| [**Dev Containers & Nix**](devops/developer-experience/devcontainers-nix/) | Reproducible dev environments for teams |
| [**Agent Evals**](devops/ai/agent-evals/) | CI/CD gates for AI agent quality & safety |

---

## How It Works

[Agent Skills](https://agentskills.io) is an open format for extending AI agents. Each `SKILL.md` has YAML frontmatter that agents load for matching, and detailed instructions that load only when activated:

```
┌────────────────────────────────────────────────────────────────┐
│  1. DISCOVER         2. MATCH            3. ACTIVATE           │
│                                                                │
│  Agent scans      →  User asks about  →  Agent reads full     │
│  skill folders       Kubernetes          SKILL.md + runs      │
│  at startup          debugging           scripts as needed    │
└────────────────────────────────────────────────────────────────┘
```

---

## 🏃 Quick Start

### Option 1: skills.sh CLI (Recommended)

The [skills](https://github.com/vercel-labs/skills) CLI discovers every `SKILL.md` in this repository and installs them into your agent's skills directory. See [CLI docs](https://skills.sh/docs/cli) and [FAQ](https://skills.sh/docs/faq).

```bash
# Install all skills
npx skills add bagelhole/DevOps-Security-Agent-Skills

# List available skills
npx skills add bagelhole/DevOps-Security-Agent-Skills --list

# Install specific skills to a specific agent
npx skills add bagelhole/DevOps-Security-Agent-Skills --skill kubernetes-ops --skill hashicorp-vault -a cursor -y

# Global install
npx skills add bagelhole/DevOps-Security-Agent-Skills -g -y

# Install a single skill by URL
npx skills add https://github.com/bagelhole/DevOps-Security-Agent-Skills/tree/main/devops/orchestration/kubernetes-ops
```

Install from a **local clone**: `npx skills add . --list` from the repo root.

### Option 2: Clone or Submodule

```bash
# Clone
git clone https://github.com/bagelhole/DevOps-Security-Agent-Skills.git ~/.skills/devops-security

# Or add as a submodule
git submodule add https://github.com/bagelhole/DevOps-Security-Agent-Skills.git .skills/devops-security
```

### Option 3: For Humans

No agent? No problem. Browse the skills, copy the configs, run the scripts. MIT licensed — go wild.

---

## 📚 Skill Catalog

<details open>
<summary><b>🔧 DevOps (40+ skills)</b></summary>

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
| [model-serving-kubernetes](devops/orchestration/model-serving-kubernetes/) | KServe and Triton model serving with canary deployments and GPU autoscaling |

### Observability
| Skill | Description |
|-------|-------------|
| [prometheus-grafana](devops/observability/prometheus-grafana/) | Metrics and dashboards |
| [opentelemetry](devops/observability/opentelemetry/) | Vendor-neutral traces, metrics, and logs |
| [ebpf-observability](devops/observability/ebpf-observability/) | Kernel-level observability with Cilium, Tetragon, and bpftrace |
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
| [llm-cost-optimization](devops/ai/llm-cost-optimization/) | Cut LLM API costs with caching, batching, model routing, and self-hosting |
| [llm-caching](devops/ai/llm-caching/) | Exact and semantic caching layers to reduce API calls by 30-70% |
| [ai-pipeline-orchestration](devops/ai/ai-pipeline-orchestration/) | Orchestrate RAG ingestion, training, and batch inference with Prefect/Airflow |
| [llmops-platform-engineering](devops/ai/llmops-platform-engineering/) | Build enterprise LLMOps platforms with evaluation gates, promotions, and governance |
| [model-registry-governance](devops/ai/model-registry-governance/) | Model metadata, approvals, lifecycle policy, and auditable promotion controls |
| [rag-observability-evals](devops/ai/rag-observability-evals/) | Measure retrieval quality, groundedness, and RAG regressions continuously |
| [ai-sre-incident-response](devops/ai/ai-sre-incident-response/) | AI-specific SRE playbooks for model outages, quality regressions, and spend spikes |

### Platform Engineering
| Skill | Description |
|-------|-------------|
| [platform-engineering](devops/platforms/platform-engineering/) | Build internal developer platforms with Backstage, Crossplane, and golden paths |

### Developer Experience
| Skill | Description |
|-------|-------------|
| [devcontainers-nix](devops/developer-experience/devcontainers-nix/) | Reproducible dev environments with Dev Containers, Nix, and Devbox |

### Release Management
| Skill | Description |
|-------|-------------|
| [git-workflow](devops/release/git-workflow/) | Branching strategies and PR workflows |
| [semantic-versioning](devops/release/semantic-versioning/) | Automated versioning and changelogs |
| [feature-flags](devops/release/feature-flags/) | LaunchDarkly, Unleash |
| [blue-green-deploy](devops/release/blue-green-deploy/) | Zero-downtime deployments |

</details>

<details>
<summary><b>🔒 Security (35+ skills)</b></summary>

### Scanning
| Skill | Description |
|-------|-------------|
| [vulnerability-scanning](security/scanning/vulnerability-scanning/) | CVE scanning with Trivy, Grype |
| [sast-scanning](security/scanning/sast-scanning/) | Semgrep, CodeQL, SonarQube |
| [dast-scanning](security/scanning/dast-scanning/) | OWASP ZAP, Nuclei |
| [dependency-scanning](security/scanning/dependency-scanning/) | Snyk, Dependabot |
| [container-scanning](security/scanning/container-scanning/) | Image vulnerability scanning |
| [sbom-supply-chain](security/scanning/sbom-supply-chain/) | SBOM generation, signing, and provenance verification |
| [supply-chain-attack-response](security/scanning/supply-chain-attack-response/) | Detect, respond to, and prevent software supply chain attacks |

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
| [openclaw-deployment-hardening](security/hardening/openclaw-deployment-hardening/) | OpenClaw CI/CD, container, and runtime hardening |

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
| [penetration-testing](security/operations/penetration-testing/) | Authorized security testing |
| [security-automation](security/operations/security-automation/) | Security workflow automation |

### AI Security
| Skill | Description |
|-------|-------------|
| [ai-agent-security](security/ai/ai-agent-security/) | Defend agents against injection, tool abuse, and exfiltration |
| [llm-app-security](security/ai/llm-app-security/) | Harden LLM app inputs, outputs, and tenant isolation |
| [mcp-server-security](security/ai/mcp-server-security/) | Secure MCP servers with auth, tool authorization, and audit logging |
| [ai-coding-agent-guardrails](security/ai/ai-coding-agent-guardrails/) | Safe Claude Code/Cursor/Codex usage with permission boundaries |
| [ai-security-hardening](security/ai/ai-security-hardening/) | Harden LLM deployments against prompt injection and model theft |
| [prompt-injection-defense](security/ai/prompt-injection-defense/) | Multi-layer prompt injection defense with detection code |
| [ai-red-teaming](security/ai/ai-red-teaming/) | Adversarial AI red team programs and testing frameworks |
| [model-supply-chain-security](security/ai/model-supply-chain-security/) | Model signing, provenance, and trusted promotion policies |

</details>

<details>
<summary><b>☁️ Infrastructure (65+ skills)</b></summary>

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
| [aws-cost-optimization](infrastructure/cloud-aws/aws-cost-optimization/) | FinOps cost reduction and spend governance |

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

### IaC
| Skill | Description |
|-------|-------------|
| [opentofu-migration](infrastructure/iac/opentofu-migration/) | Migrate from Terraform to the open-source OpenTofu fork |

### Server Management
| Skill | Description |
|-------|-------------|
| [linux-administration](infrastructure/servers/linux-administration/) | Core Linux admin |
| [windows-server](infrastructure/servers/windows-server/) | Windows administration |
| [ssh-configuration](infrastructure/servers/ssh-configuration/) | SSH and bastion hosts |
| [user-management](infrastructure/servers/user-management/) | Users, groups, sudo |
| [systemd-services](infrastructure/servers/systemd-services/) | Services and timers |
| [performance-tuning](infrastructure/servers/performance-tuning/) | System optimization |
| [gpu-server-management](infrastructure/servers/gpu-server-management/) | NVIDIA GPU driver setup, MIG partitioning, DCGM monitoring |

### Networking
| Skill | Description |
|-------|-------------|
| [dns-management](infrastructure/networking/dns-management/) | DNS and Route53 |
| [load-balancing](infrastructure/networking/load-balancing/) | ALB, nginx, HAProxy |
| [cdn-setup](infrastructure/networking/cdn-setup/) | CloudFront, Cloudflare |
| [reverse-proxy](infrastructure/networking/reverse-proxy/) | nginx, Traefik |
| [service-mesh](infrastructure/networking/service-mesh/) | Istio, Linkerd |
| [llm-gateway](infrastructure/networking/llm-gateway/) | Unified LLM API gateway with routing, rate limiting, and semantic caching |
| [ai-inference-service-mesh](infrastructure/networking/ai-inference-service-mesh/) | Service mesh for mTLS, canary inference routing, and resilient AI traffic |

### Databases
| Skill | Description |
|-------|-------------|
| [postgresql](infrastructure/databases/postgresql/) | PostgreSQL admin |
| [mysql](infrastructure/databases/mysql/) | MySQL/MariaDB |
| [planetscale](infrastructure/databases/planetscale/) | Branch-based MySQL schema deployments |
| [mongodb](infrastructure/databases/mongodb/) | MongoDB clusters |
| [redis](infrastructure/databases/redis/) | Redis caching |
| [database-backups](infrastructure/databases/database-backups/) | Backup strategies |
| [vector-database-ops](infrastructure/databases/vector-database-ops/) | Qdrant, Weaviate, and pgvector for AI search and RAG |

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
| [ollama-stack](infrastructure/local-ai/ollama-stack/) | Private local inference stack with Ollama and Open WebUI |
| [mac-mini-llm-lab](infrastructure/local-ai/mac-mini-llm-lab/) | Mac mini setup for always-on local LLM serving |
| [openclaw-local-mac-mini](infrastructure/local-ai/openclaw-local-mac-mini/) | OpenClaw local development and Mac mini hosting |
| [openclaw-security-hardening](infrastructure/local-ai/openclaw-security-hardening/) | OpenClaw host, auth, secrets, and network hardening |
| [vllm-server](infrastructure/local-ai/vllm-server/) | High-throughput LLM serving with vLLM and PagedAttention |
| [llm-inference-scaling](infrastructure/local-ai/llm-inference-scaling/) | Auto-scale LLM inference on Kubernetes with KEDA |
| [rag-infrastructure](infrastructure/local-ai/rag-infrastructure/) | Production RAG with vector stores, hybrid search, and reranking |
| [llm-fine-tuning](infrastructure/local-ai/llm-fine-tuning/) | QLoRA and full fine-tuning with Axolotl and DeepSpeed |
| [gpu-kubernetes-operations](infrastructure/local-ai/gpu-kubernetes-operations/) | GPU Kubernetes with MIG, autoscaling, and AI cost controls |
| [multi-tenant-llm-hosting](infrastructure/local-ai/multi-tenant-llm-hosting/) | Multi-tenant LLM hosting with quotas and isolation |

### IT Operations
| Skill | Description |
|-------|-------------|
| [startup-it-troubleshooting](infrastructure/it/startup-it-troubleshooting/) | Practical IT troubleshooting for small teams |
| [mdm-device-management](infrastructure/it/mdm-device-management/) | Manage and secure company devices with Fleet, Jamf, or Intune |
| [identity-access-management](infrastructure/it/identity-access-management/) | SSO, SCIM provisioning, and MFA with Google Workspace or Okta |
| [saas-security-posture](infrastructure/it/saas-security-posture/) | Audit and harden your SaaS stack (GitHub, Slack, Google Workspace) |

</details>

<details>
<summary><b>📋 Compliance (20+ skills)</b></summary>

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

Found a gap? Want to add a skill? PRs are welcome!

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

<div align="center">

### If this made your agent smarter, **[star this repo](https://github.com/bagelhole/DevOps-Security-Agent-Skills)** — it helps others find it.

Built by [Toby Miller](https://github.com/bagelhole)

**[⬆ Back to Top](#-devops--security-agent-skills)**

</div>
