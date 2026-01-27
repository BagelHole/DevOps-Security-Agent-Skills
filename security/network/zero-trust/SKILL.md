---
name: zero-trust
description: Implement zero-trust network architecture. Configure identity-based access, micro-segmentation, and continuous verification. Use when implementing modern security architectures.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Zero Trust Architecture

Implement "never trust, always verify" security model.

## Core Principles

```yaml
zero_trust_principles:
  - Verify explicitly (authenticate all access)
  - Least privilege access
  - Assume breach (micro-segmentation)
  - Continuous validation
  - End-to-end encryption
```

## Identity-Based Access

```yaml
# Service mesh mTLS
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: frontend-to-backend
spec:
  selector:
    matchLabels:
      app: backend
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/frontend"]
```

## Network Segmentation

```yaml
# Kubernetes Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## Implementation Steps

1. Identify sensitive resources
2. Map access patterns
3. Implement strong authentication
4. Apply micro-segmentation
5. Enable logging and monitoring
6. Continuous verification

## Best Practices

- Identity-aware proxies
- Device trust verification
- Context-based access
- Encrypted communications
- Continuous monitoring

## Related Skills

- [service-mesh](../../../infrastructure/networking/service-mesh/) - mTLS implementation
- [kubernetes-hardening](../../hardening/kubernetes-hardening/) - K8s security
