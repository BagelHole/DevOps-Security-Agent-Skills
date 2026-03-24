---
name: platform-engineering
description: Build internal developer platforms (IDPs) with self-service infrastructure, golden paths, and developer portals using Backstage, Crossplane, and score.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Platform Engineering

Platform engineering is the discipline of building and maintaining internal developer platforms (IDPs) that enable self-service capabilities for software engineering teams. The goal is to reduce cognitive load, standardize infrastructure provisioning, and accelerate delivery while maintaining governance and security guardrails.

---

## 1. When to Use

Adopt platform engineering practices when your organization experiences:

- **Cognitive overload on dev teams** -- developers spend more time on infrastructure wiring than writing business logic.
- **Inconsistent environments** -- every team provisions infrastructure differently, causing drift and outages.
- **Slow onboarding** -- new engineers take weeks to get a working development environment.
- **Repeated toil** -- the same Terraform/Helm/CI boilerplate is copy-pasted across dozens of repos.
- **Compliance bottlenecks** -- security and ops reviews gate every deployment, slowing release cadence.
- **Scale inflection points** -- you have 5+ teams and shared infrastructure concerns (networking, observability, secrets).

Platform engineering is NOT about replacing ops with a portal. It is about encoding organizational standards into reusable, self-service abstractions that dev teams consume through golden paths.

---

## 2. Backstage Setup

[Backstage](https://backstage.io) is the leading open-source developer portal framework, originally created at Spotify.

### Installation

```bash
# Prerequisites: Node.js 18+, yarn 1.x
npx @backstage/create-app@latest

# Follow the prompts -- name your app, e.g., "internal-platform"
cd internal-platform

# Start the development server
yarn dev
```

### Production Docker Build

```dockerfile
# Dockerfile for Backstage production image
FROM node:18-bookworm-slim AS build
WORKDIR /app

COPY package.json yarn.lock ./
COPY packages/ packages/
COPY plugins/ plugins/

RUN yarn install --frozen-lockfile
RUN yarn tsc
RUN yarn build:backend

FROM node:18-bookworm-slim
WORKDIR /app

COPY --from=build /app/packages/backend/dist/ ./
COPY --from=build /app/node_modules/ ./node_modules/
COPY app-config.yaml app-config.production.yaml ./

ENV NODE_ENV=production
CMD ["node", "packages/backend", "--config", "app-config.production.yaml"]
```

### Core app-config.yaml

```yaml
# app-config.yaml
app:
  title: Internal Developer Platform
  baseUrl: http://localhost:3000

organization:
  name: MyOrg

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, System, API, Resource, Location, Template]
  locations:
    - type: url
      target: https://github.com/myorg/software-catalog/blob/main/catalog-info.yaml
    - type: url
      target: https://github.com/myorg/backstage-templates/blob/main/all-templates.yaml
```

---

## 3. Crossplane for Self-Service Infrastructure

Crossplane extends Kubernetes to provision and manage cloud infrastructure through declarative YAML.

### Install Crossplane

```bash
# Add the Crossplane Helm repo
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

# Install Crossplane into its own namespace
helm install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace \
  --set args='{"--enable-composition-revisions"}'

# Install the AWS provider
kubectl apply -f - <<EOF
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/upbound/provider-family-aws:v1.1.0
EOF

# Configure AWS credentials
kubectl create secret generic aws-creds \
  -n crossplane-system \
  --from-file=creds=./aws-credentials.txt

kubectl apply -f - <<EOF
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: creds
EOF
```

### CompositeResourceDefinition (XRD)

This defines a new platform API that developers consume without knowing the underlying cloud resources.

```yaml
# xrd-application-database.yaml
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xapplicationdatabases.platform.myorg.io
spec:
  group: platform.myorg.io
  names:
    kind: XApplicationDatabase
    plural: xapplicationdatabases
  claimNames:
    kind: ApplicationDatabase
    plural: applicationdatabases
  versions:
    - name: v1alpha1
      served: true
      referenceable: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                parameters:
                  type: object
                  properties:
                    engine:
                      type: string
                      enum: ["postgres", "mysql"]
                      default: "postgres"
                    engineVersion:
                      type: string
                      default: "15"
                    storageGB:
                      type: integer
                      minimum: 20
                      maximum: 500
                      default: 20
                    instanceSize:
                      type: string
                      enum: ["small", "medium", "large"]
                      default: "small"
                    environment:
                      type: string
                      enum: ["dev", "staging", "prod"]
                  required:
                    - environment
```

### Composition (AWS RDS)

```yaml
# composition-aws-database.yaml
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: applicationdatabase-aws
  labels:
    provider: aws
spec:
  compositeTypeRef:
    apiVersion: platform.myorg.io/v1alpha1
    kind: XApplicationDatabase
  resources:
    - name: rds-instance
      base:
        apiVersion: rds.aws.upbound.io/v1beta1
        kind: Instance
        spec:
          forProvider:
            region: us-east-1
            allocatedStorage: 20
            autoMinorVersionUpgrade: true
            backupRetentionPeriod: 7
            dbName: appdb
            deletionProtection: false
            publiclyAccessible: false
            skipFinalSnapshot: true
            storageEncrypted: true
            storageType: gp3
            vpcSecurityGroupIdSelector:
              matchLabels:
                platform.myorg.io/network: shared
            dbSubnetGroupNameSelector:
              matchLabels:
                platform.myorg.io/network: shared
      patches:
        - type: FromCompositeFieldPath
          fromFieldPath: spec.parameters.engine
          toFieldPath: spec.forProvider.engine
        - type: FromCompositeFieldPath
          fromFieldPath: spec.parameters.engineVersion
          toFieldPath: spec.forProvider.engineVersion
        - type: FromCompositeFieldPath
          fromFieldPath: spec.parameters.storageGB
          toFieldPath: spec.forProvider.allocatedStorage
        - type: CombineFromComposite
          combine:
            variables:
              - fromFieldPath: spec.parameters.instanceSize
            strategy: map
            map:
              small: db.t3.micro
              medium: db.t3.medium
              large: db.r6g.large
          toFieldPath: spec.forProvider.instanceClass
    - name: db-secret
      base:
        apiVersion: secretstores.aws.upbound.io/v1beta1
        kind: Secret
        spec:
          forProvider:
            region: us-east-1
      patches:
        - type: FromCompositeFieldPath
          fromFieldPath: metadata.name
          toFieldPath: spec.forProvider.name
          transforms:
            - type: string
              string:
                fmt: "platform/%s/db-credentials"
```

### Developer Claim (what devs actually write)

```yaml
# my-app-database.yaml
apiVersion: platform.myorg.io/v1alpha1
kind: ApplicationDatabase
metadata:
  name: orders-db
  namespace: team-commerce
spec:
  parameters:
    engine: postgres
    engineVersion: "15"
    storageGB: 50
    instanceSize: medium
    environment: staging
```

---

## 4. Golden Paths

Golden paths are opinionated, well-supported paths through your tech stack that teams can follow to ship quickly.

### Backstage Software Template

```yaml
# template-nodejs-service.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: nodejs-service
  title: Node.js Microservice
  description: Create a production-ready Node.js service with CI/CD, monitoring, and Kubernetes manifests.
  tags:
    - recommended
    - nodejs
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Service Details
      required:
        - name
        - owner
        - system
      properties:
        name:
          title: Service Name
          type: string
          pattern: "^[a-z0-9-]+$"
          ui:autofocus: true
        description:
          title: Description
          type: string
        owner:
          title: Owner Team
          type: string
          ui:field: OwnerPicker
          ui:options:
            catalogFilter:
              kind: Group
        system:
          title: System
          type: string
          ui:field: EntityPicker
          ui:options:
            catalogFilter:
              kind: System
    - title: Infrastructure
      properties:
        database:
          title: Database
          type: string
          enum: ["none", "postgres", "mysql"]
          default: "none"
        cacheLayer:
          title: Cache
          type: string
          enum: ["none", "redis"]
          default: "none"
        environment:
          title: Target Environment
          type: string
          enum: ["dev", "staging", "prod"]
          default: "dev"
  steps:
    - id: fetch-template
      name: Fetch Skeleton
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          owner: ${{ parameters.owner }}
          system: ${{ parameters.system }}
          description: ${{ parameters.description }}
          database: ${{ parameters.database }}
          cacheLayer: ${{ parameters.cacheLayer }}
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ["github.com"]
        repoUrl: github.com?owner=myorg&repo=${{ parameters.name }}
        repoVisibility: internal
        defaultBranch: main
        protectDefaultBranch: true
        requireCodeOwnerReviews: true
    - id: create-argocd-app
      name: Register with ArgoCD
      action: argocd:create-resources
      input:
        appName: ${{ parameters.name }}
        argoInstance: main
        namespace: ${{ parameters.name }}
        repoUrl: https://github.com/myorg/${{ parameters.name }}
        path: deploy/k8s
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: /catalog-info.yaml
  output:
    links:
      - title: Repository
        url: ${{ steps.publish.output.remoteUrl }}
      - title: Open in Backstage
        icon: catalog
        entityRef: ${{ steps.register.output.entityRef }}
```

### Cookiecutter Template Structure

```
golden-path-nodejs/
  cookiecutter.json
  {{cookiecutter.service_name}}/
    Dockerfile
    package.json
    tsconfig.json
    src/
      index.ts
      health.ts
    deploy/
      k8s/
        deployment.yaml
        service.yaml
        ingress.yaml
    .github/
      workflows/
        ci.yaml
        deploy.yaml
    catalog-info.yaml
```

```json
// cookiecutter.json
{
  "service_name": "my-service",
  "description": "A new microservice",
  "owner_team": "platform",
  "port": "3000",
  "database": ["none", "postgres", "mysql"],
  "node_version": "18"
}
```

---

## 5. Service Catalog

### catalog-info.yaml for a Microservice

```yaml
# catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: orders-service
  description: Handles order creation, fulfillment, and tracking.
  annotations:
    backstage.io/techdocs-ref: dir:.
    github.com/project-slug: myorg/orders-service
    backstage.io/kubernetes-id: orders-service
    backstage.io/kubernetes-namespace: team-commerce
    argocd/app-name: orders-service
    pagerduty.com/integration-key: ${PAGERDUTY_KEY}
    grafana/dashboard-selector: "app=orders-service"
  tags:
    - nodejs
    - grpc
  links:
    - url: https://grafana.internal/d/orders-service
      title: Grafana Dashboard
      icon: dashboard
    - url: https://runbooks.internal/orders-service
      title: Runbook
      icon: docs
spec:
  type: service
  lifecycle: production
  owner: team-commerce
  system: commerce-platform
  providesApis:
    - orders-api
  consumesApis:
    - inventory-api
    - payments-api
  dependsOn:
    - resource:orders-db
    - resource:orders-cache
```

### API Entity

```yaml
# orders-api.yaml
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: orders-api
  description: Order management API
  annotations:
    backstage.io/techdocs-ref: dir:.
spec:
  type: openapi
  lifecycle: production
  owner: team-commerce
  system: commerce-platform
  definition:
    $text: ./api/openapi.yaml
```

### TechDocs Configuration

```yaml
# mkdocs.yml (in the service repo root)
site_name: Orders Service
site_description: Technical documentation for the Orders Service
nav:
  - Home: index.md
  - Architecture: architecture.md
  - API Reference: api-reference.md
  - Runbook: runbook.md
  - ADRs:
      - adr/001-choose-grpc.md
      - adr/002-event-sourcing.md

plugins:
  - techdocs-core

markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
```

Enable TechDocs in `app-config.yaml`:

```yaml
techdocs:
  builder: external
  generator:
    runIn: docker
  publisher:
    type: awsS3
    awsS3:
      bucketName: myorg-techdocs
      region: us-east-1
      credentials:
        roleArn: arn:aws:iam::123456789012:role/techdocs-publisher
```

---

## 6. Developer Portal -- Backstage Plugins

### Kubernetes Plugin

```bash
# Install Kubernetes plugin
yarn --cwd packages/app add @backstage/plugin-kubernetes
yarn --cwd packages/backend add @backstage/plugin-kubernetes-backend
```

Backend configuration in `app-config.yaml`:

```yaml
kubernetes:
  serviceLocatorMethod:
    type: multiTenant
  clusterLocatorMethods:
    - type: config
      clusters:
        - url: https://k8s-dev.internal:6443
          name: dev-cluster
          authProvider: serviceAccount
          serviceAccountToken: ${K8S_DEV_TOKEN}
          skipTLSVerify: false
          caData: ${K8S_DEV_CA_DATA}
        - url: https://k8s-prod.internal:6443
          name: prod-cluster
          authProvider: serviceAccount
          serviceAccountToken: ${K8S_PROD_TOKEN}
          skipTLSVerify: false
          caData: ${K8S_PROD_CA_DATA}
```

### CI/CD Plugin (GitHub Actions)

```yaml
# app-config.yaml addition
proxy:
  endpoints:
    /github-actions:
      target: https://api.github.com
      headers:
        Authorization: Bearer ${GITHUB_TOKEN}
        Accept: application/vnd.github+json
```

### Monitoring Plugin (Grafana)

```yaml
# app-config.yaml addition
grafana:
  domain: https://grafana.internal
  unifiedAlerting: true
proxy:
  endpoints:
    /grafana/api:
      target: https://grafana.internal
      headers:
        Authorization: Bearer ${GRAFANA_API_TOKEN}
```

---

## 7. Score Specification

[Score](https://score.dev) provides a platform-agnostic workload specification so developers describe what they need, and the platform decides how to provision it.

### score.yaml

```yaml
# score.yaml
apiVersion: score.dev/v1b1
metadata:
  name: orders-service
  tags:
    team: commerce
    tier: critical

containers:
  main:
    image: .
    variables:
      PORT: "3000"
      DB_HOST: ${resources.db.host}
      DB_PORT: ${resources.db.port}
      DB_NAME: ${resources.db.name}
      DB_USER: ${resources.db.username}
      DB_PASSWORD: ${resources.db.password}
      CACHE_HOST: ${resources.cache.host}
      CACHE_PORT: ${resources.cache.port}
    ports:
      http:
        port: 3000
        protocol: TCP
    readinessProbe:
      httpGet:
        path: /healthz
        port: 3000
    livenessProbe:
      httpGet:
        path: /healthz
        port: 3000
    resources:
      limits:
        cpu: "500m"
        memory: "512Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"

resources:
  db:
    type: postgres
    properties:
      host:
      port:
      name:
        default: orders
      username:
      password:
  cache:
    type: redis
    properties:
      host:
      port:
  dns:
    type: dns
    properties:
      host:
  sqs:
    type: aws-sqs
    properties:
      queue_url:
      arn:

service:
  ports:
    http:
      port: 80
      targetPort: 3000
```

### Generating Platform-Specific Manifests

```bash
# Install score-compose for local development
brew install score-spec/tap/score-compose

# Generate docker-compose from score.yaml
score-compose init
score-compose generate score.yaml

# Install score-k8s for Kubernetes targets
brew install score-spec/tap/score-k8s

# Generate Kubernetes manifests from score.yaml
score-k8s init
score-k8s generate score.yaml
```

---

## 8. Self-Service Workflows

### Terraform Module Exposed via Platform API

```hcl
# modules/environment/main.tf
variable "team_name" {
  type        = string
  description = "Name of the requesting team"
}

variable "environment" {
  type        = string
  description = "Environment tier"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "services" {
  type = list(object({
    name     = string
    port     = number
    replicas = number
  }))
  description = "List of services to deploy"
}

module "namespace" {
  source      = "../k8s-namespace"
  name        = "${var.team_name}-${var.environment}"
  labels = {
    "platform.myorg.io/team"        = var.team_name
    "platform.myorg.io/environment" = var.environment
  }
}

module "network_policy" {
  source    = "../network-policy"
  namespace = module.namespace.name
  allow_ingress_from = [
    "istio-system",
    "monitoring"
  ]
}

module "resource_quota" {
  source    = "../resource-quota"
  namespace = module.namespace.name
  cpu_limit = var.environment == "prod" ? "16" : "4"
  mem_limit = var.environment == "prod" ? "32Gi" : "8Gi"
}

module "database" {
  for_each  = { for s in var.services : s.name => s if lookup(s, "database", false) }
  source    = "../rds-instance"
  name      = "${var.team_name}-${each.key}"
  engine    = "postgres"
  environment = var.environment
}

output "namespace" {
  value = module.namespace.name
}

output "kubeconfig_command" {
  value = "kubectl config set-context ${var.team_name}-${var.environment} --namespace=${module.namespace.name}"
}
```

### Environment Request CRD (Kubernetes Operator Pattern)

```yaml
# environment-request.yaml
apiVersion: platform.myorg.io/v1alpha1
kind: EnvironmentRequest
metadata:
  name: commerce-staging
  namespace: platform-system
spec:
  team: commerce
  environment: staging
  ttl: 72h              # auto-cleanup for non-prod
  services:
    - name: orders-service
      port: 3000
      replicas: 2
      database: true
    - name: inventory-service
      port: 3001
      replicas: 2
      database: true
    - name: frontend
      port: 8080
      replicas: 1
      database: false
  notifications:
    slack: "#team-commerce-platform"
```

### Backstage Self-Service Action (Custom Plugin)

```typescript
// plugins/platform-actions/src/actions/provision-environment.ts
import { createTemplateAction } from '@backstage/plugin-scaffolder-node';
import { Config } from '@backstage/config';

export const provisionEnvironmentAction = (config: Config) => {
  return createTemplateAction<{
    team: string;
    environment: string;
    services: Array<{ name: string; port: number; replicas: number }>;
  }>({
    id: 'platform:provision-environment',
    description: 'Provisions a complete environment for a team',
    schema: {
      input: {
        type: 'object',
        required: ['team', 'environment'],
        properties: {
          team: { type: 'string', title: 'Team Name' },
          environment: {
            type: 'string',
            title: 'Environment',
            enum: ['dev', 'staging', 'prod'],
          },
          services: {
            type: 'array',
            title: 'Services',
            items: {
              type: 'object',
              properties: {
                name: { type: 'string' },
                port: { type: 'number' },
                replicas: { type: 'number' },
              },
            },
          },
        },
      },
    },
    async handler(ctx) {
      const { team, environment, services } = ctx.input;
      const platformApiUrl = config.getString('platform.apiUrl');

      ctx.logger.info(`Provisioning ${environment} for team ${team}`);

      const response = await fetch(`${platformApiUrl}/environments`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ team, environment, services }),
      });

      if (!response.ok) {
        throw new Error(`Provisioning failed: ${response.statusText}`);
      }

      const result = await response.json();
      ctx.logger.info(`Environment ready: ${result.namespace}`);
      ctx.output('namespace', result.namespace);
      ctx.output('dashboardUrl', result.dashboardUrl);
    },
  });
};
```

---

## 9. Platform Metrics

### DORA Metrics Collection (Prometheus)

```yaml
# prometheus-rules-dora.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: dora-metrics
  namespace: monitoring
spec:
  groups:
    - name: dora.deployment_frequency
      interval: 1h
      rules:
        - record: dora:deployment_frequency:rate1d
          expr: |
            sum by (team, service) (
              increase(argocd_app_sync_total{phase="Succeeded"}[1d])
            )
        - record: dora:deployment_frequency:rate7d
          expr: |
            sum by (team, service) (
              increase(argocd_app_sync_total{phase="Succeeded"}[7d])
            ) / 7

    - name: dora.lead_time
      interval: 1h
      rules:
        - record: dora:lead_time_seconds:avg
          expr: |
            avg by (team, service) (
              github_workflow_duration_seconds{workflow="deploy", status="success"}
            )

    - name: dora.change_failure_rate
      interval: 1h
      rules:
        - record: dora:change_failure_rate:ratio
          expr: |
            sum by (team, service) (
              increase(argocd_app_sync_total{phase="Failed"}[7d])
            )
            /
            sum by (team, service) (
              increase(argocd_app_sync_total[7d])
            )

    - name: dora.mttr
      interval: 1h
      rules:
        - record: dora:mttr_seconds:avg
          expr: |
            avg by (team, service) (
              pagerduty_incident_resolve_duration_seconds
            )
```

### Grafana Dashboard (JSON Model Snippet)

```json
{
  "dashboard": {
    "title": "Platform Engineering -- DORA & Adoption",
    "panels": [
      {
        "title": "Deployment Frequency (daily avg, 7d)",
        "type": "stat",
        "targets": [
          { "expr": "dora:deployment_frequency:rate7d", "legendFormat": "{{team}}/{{service}}" }
        ]
      },
      {
        "title": "Lead Time for Changes",
        "type": "gauge",
        "targets": [
          { "expr": "dora:lead_time_seconds:avg / 3600", "legendFormat": "{{team}} (hours)" }
        ]
      },
      {
        "title": "Change Failure Rate",
        "type": "gauge",
        "targets": [
          { "expr": "dora:change_failure_rate:ratio * 100", "legendFormat": "{{team}} %" }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "steps": [
                { "color": "green", "value": 0 },
                { "color": "yellow", "value": 15 },
                { "color": "red", "value": 30 }
              ]
            }
          }
        }
      },
      {
        "title": "Platform Adoption -- Scaffolded Repos",
        "type": "timeseries",
        "targets": [
          { "expr": "sum(backstage_scaffolder_task_count_total{status='completed'})", "legendFormat": "Total scaffolded" }
        ]
      }
    ]
  }
}
```

### Developer Experience Survey (Automated Collection)

```yaml
# cronjob-devex-survey.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: devex-survey-reminder
  namespace: platform-system
spec:
  schedule: "0 10 1 */3 *"     # quarterly, 1st of month at 10am
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: survey-bot
              image: myorg/platform-bot:latest
              env:
                - name: SLACK_WEBHOOK
                  valueFrom:
                    secretKeyRef:
                      name: platform-bot-secrets
                      key: slack-webhook
                - name: SURVEY_URL
                  value: "https://forms.internal/devex-q1"
              command:
                - /bin/sh
                - -c
                - |
                  curl -X POST "$SLACK_WEBHOOK" \
                    -H 'Content-Type: application/json' \
                    -d "{
                      \"text\": \"Hey team! It's time for our quarterly Developer Experience survey. Your feedback directly shapes platform priorities. Please take 5 minutes: ${SURVEY_URL}\"
                    }"
          restartPolicy: OnFailure
```

---

## 10. Governance -- Policy Enforcement

### OPA/Gatekeeper Constraint Templates

```yaml
# constraint-template-approved-base-images.yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8sapprovedbaseimages
spec:
  crd:
    spec:
      names:
        kind: K8sApprovedBaseImages
      validation:
        openAPIV3Schema:
          type: object
          properties:
            allowedRegistries:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8sapprovedbaseimages

        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not startswith_any(container.image, input.parameters.allowedRegistries)
          msg := sprintf(
            "Container '%s' uses image '%s' which is not from an approved registry. Allowed: %v",
            [container.name, container.image, input.parameters.allowedRegistries]
          )
        }

        startswith_any(str, prefixes) {
          prefix := prefixes[_]
          startswith(str, prefix)
        }
---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sApprovedBaseImages
metadata:
  name: approved-registries
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaceSelector:
      matchExpressions:
        - key: platform.myorg.io/environment
          operator: Exists
  parameters:
    allowedRegistries:
      - "myorg.azurecr.io/"
      - "gcr.io/myorg-"
      - "public.ecr.aws/myorg/"
```

### Kyverno Policies

```yaml
# kyverno-require-labels.yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-platform-labels
  annotations:
    policies.kyverno.io/title: Require Platform Labels
    policies.kyverno.io/description: >-
      All workloads must include standard platform labels for
      cost attribution, ownership tracking, and incident routing.
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: check-required-labels
      match:
        any:
          - resources:
              kinds:
                - Deployment
                - StatefulSet
                - DaemonSet
      validate:
        message: >-
          All workloads must have the labels: platform.myorg.io/team,
          platform.myorg.io/environment, platform.myorg.io/cost-center.
          Found labels: {{request.object.metadata.labels}}
        pattern:
          metadata:
            labels:
              platform.myorg.io/team: "?*"
              platform.myorg.io/environment: "?*"
              platform.myorg.io/cost-center: "?*"
    - name: inject-default-security-context
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        patchStrategicMerge:
          spec:
            securityContext:
              runAsNonRoot: true
              seccompProfile:
                type: RuntimeDefault
            containers:
              - (name): "*"
                securityContext:
                  allowPrivilegeEscalation: false
                  readOnlyRootFilesystem: true
                  capabilities:
                    drop:
                      - ALL
```

### Platform-Level Network Policies

```yaml
# network-policy-platform-defaults.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: platform-default-deny
  namespace: "{{namespace}}"
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              platform.myorg.io/system: ingress-gateway
        - namespaceSelector:
            matchLabels:
              platform.myorg.io/system: monitoring
          podSelector:
            matchLabels:
              app: prometheus
  egress:
    - to:
        - namespaceSelector: {}
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
    - to:
        - namespaceSelector:
            matchLabels:
              name: "{{namespace}}"
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - 10.0.0.0/8
              - 172.16.0.0/12
              - 192.168.0.0/16
      ports:
        - protocol: TCP
          port: 443
```

---

## Summary

A well-built internal developer platform combines these layers:

| Layer | Tools | Purpose |
|---|---|---|
| Portal | Backstage | Single pane of glass for developers |
| Catalog | catalog-info.yaml, APIs | Discoverability and ownership |
| Golden Paths | Software Templates, Cookiecutter | Fast, standardized project scaffolding |
| Self-Service Infra | Crossplane, Terraform | Declarative cloud resource provisioning |
| Workload Spec | Score | Platform-agnostic app definitions |
| Governance | OPA, Kyverno, Network Policies | Automated policy enforcement |
| Metrics | DORA, DevEx surveys | Measure platform value and adoption |

The platform team ships the platform as a product. Developers are the customers. Measure success by adoption, not by mandate.
