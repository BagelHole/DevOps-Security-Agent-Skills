# ArgoCD GitOps Patterns

## Application Definition

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/repo
    targetRevision: HEAD
    path: k8s/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## Sync Waves

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-1"  # Deploy first
---
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "0"   # Default
---
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"   # Deploy last
```

## ApplicationSet

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: myapp-set
spec:
  generators:
    - list:
        elements:
          - env: dev
            cluster: dev-cluster
          - env: prod
            cluster: prod-cluster
  template:
    metadata:
      name: 'myapp-{{env}}'
    spec:
      source:
        repoURL: https://github.com/org/repo
        path: 'k8s/overlays/{{env}}'
      destination:
        server: '{{cluster}}'
        namespace: myapp
```

## Multi-Cluster

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: prod-cluster
  labels:
    argocd.argoproj.io/secret-type: cluster
stringData:
  name: prod
  server: https://prod-cluster.example.com
  config: |
    {
      "bearerToken": "...",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "..."
      }
    }
```

## App of Apps

```yaml
# Root application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
spec:
  source:
    path: apps/  # Contains Application manifests
  destination:
    namespace: argocd
```

## CLI Commands

```bash
# Login
argocd login argocd.example.com

# Sync
argocd app sync myapp
argocd app sync myapp --prune

# Rollback
argocd app rollback myapp

# Diff
argocd app diff myapp

# History
argocd app history myapp
```
