---
name: kubernetes-hardening
description: Implement Kubernetes security contexts, Pod Security Standards, and network policies. Secure cluster components and workloads. Use when hardening Kubernetes deployments or meeting security compliance.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Kubernetes Hardening

Secure Kubernetes clusters and workloads.

## When to Use This Skill

Use this skill when:
- Hardening Kubernetes clusters
- Implementing Pod Security Standards
- Configuring network policies
- Meeting security compliance

## Pod Security Standards

```yaml
# Namespace with restricted policy
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: myapp:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
```

## Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - port: 8080
```

## RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-reader
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-reader-binding
subjects:
- kind: ServiceAccount
  name: myapp
roleRef:
  kind: Role
  name: app-reader
  apiGroup: rbac.authorization.k8s.io
```

## Best Practices

- Enable Pod Security Standards
- Implement network policies
- Use RBAC with least privilege
- Enable audit logging
- Secure etcd with encryption
- Use service mesh for mTLS
- Regular security scanning

## Related Skills

- [kubernetes-ops](../../../devops/orchestration/kubernetes-ops/) - K8s operations
- [container-hardening](../container-hardening/) - Container security
