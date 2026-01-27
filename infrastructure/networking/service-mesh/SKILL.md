---
name: service-mesh
description: Implement Istio and Linkerd service meshes. Configure mTLS, traffic management, and observability. Use when managing microservices communication.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Service Mesh

Implement service-to-service communication management.

## Istio Installation

```bash
istioctl install --set profile=demo

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled
```

## Traffic Management

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: myapp
        subset: canary
  - route:
    - destination:
        host: myapp
        subset: stable
      weight: 90
    - destination:
        host: myapp
        subset: canary
      weight: 10
```

## mTLS

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

## Best Practices

- Enable strict mTLS
- Implement circuit breakers
- Use traffic shifting for deployments
- Monitor with Kiali and Jaeger
