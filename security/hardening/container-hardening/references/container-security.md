# Container Security Best Practices

## Dockerfile Hardening

```dockerfile
# Use minimal base image
FROM gcr.io/distroless/base-debian12

# Or Alpine
FROM alpine:3.19

# Non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -D appuser
USER appuser

# Read-only filesystem
# (Set at runtime with --read-only)

# No new privileges
# (Set at runtime with --security-opt=no-new-privileges)
```

## Security Scanning

```bash
# Trivy scan
trivy image --severity HIGH,CRITICAL myimage:latest

# Grype scan
grype myimage:latest --fail-on high

# Docker Scout
docker scout cves myimage:latest
```

## Runtime Security

```yaml
# Kubernetes securityContext
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  seccompProfile:
    type: RuntimeDefault
```

## Docker Run Hardening

```bash
docker run \
  --read-only \
  --tmpfs /tmp \
  --security-opt=no-new-privileges:true \
  --cap-drop=ALL \
  --user 1000:1000 \
  --memory=512m \
  --cpus=0.5 \
  myimage
```

## Image Signing

```bash
# Cosign
cosign sign --key cosign.key myimage:latest
cosign verify --key cosign.pub myimage:latest

# Docker Content Trust
export DOCKER_CONTENT_TRUST=1
docker push myimage:latest
```

## Network Policies

```yaml
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

## Checklist

- [ ] Use minimal base images
- [ ] Run as non-root
- [ ] Drop all capabilities
- [ ] Read-only filesystem
- [ ] No privilege escalation
- [ ] Scan for vulnerabilities
- [ ] Sign images
- [ ] Implement network policies
- [ ] Use secrets management
- [ ] Enable audit logging
