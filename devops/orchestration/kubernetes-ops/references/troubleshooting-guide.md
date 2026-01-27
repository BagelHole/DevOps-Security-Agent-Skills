# Kubernetes Troubleshooting Guide

## Common Issues and Solutions

### Pod Issues

#### Pod Stuck in Pending
```bash
# Check events
kubectl describe pod <pod-name> -n <namespace>

# Common causes:
# - Insufficient resources
kubectl describe nodes | grep -A 5 "Allocated resources"

# - No matching nodes (taints/tolerations)
kubectl get nodes -o json | jq '.items[].spec.taints'

# - PVC not bound
kubectl get pvc -n <namespace>
```

#### Pod in CrashLoopBackOff
```bash
# Check logs
kubectl logs <pod-name> -n <namespace> --previous

# Check container exit code
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}'

# Common exit codes:
# 0 - Success (check livenessProbe)
# 1 - Application error
# 137 - OOMKilled (increase memory)
# 139 - Segmentation fault
# 143 - SIGTERM received
```

#### Pod in ImagePullBackOff
```bash
# Check image name
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[0].image}'

# Verify image exists
docker pull <image>

# Check imagePullSecrets
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.imagePullSecrets}'
kubectl get secret <secret-name> -n <namespace> -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d
```

### Service Issues

#### Service Not Accessible
```bash
# Verify endpoints exist
kubectl get endpoints <service-name> -n <namespace>

# Check selector matches pod labels
kubectl get svc <service-name> -n <namespace> -o jsonpath='{.spec.selector}'
kubectl get pods -n <namespace> --show-labels

# Test from within cluster
kubectl run debug --rm -it --image=busybox -- wget -qO- http://<service>.<namespace>.svc.cluster.local
```

#### DNS Resolution Issues
```bash
# Test DNS from pod
kubectl run dns-test --rm -it --image=busybox -- nslookup kubernetes.default

# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns
```

### Node Issues

#### Node NotReady
```bash
# Check node conditions
kubectl describe node <node-name> | grep -A 20 Conditions

# Check kubelet status
systemctl status kubelet

# Check kubelet logs
journalctl -u kubelet -f

# Common causes:
# - Disk pressure
# - Memory pressure
# - Network issues
# - Container runtime issues
```

#### Node Disk Pressure
```bash
# Check disk usage
kubectl describe node <node-name> | grep -A 3 "Allocated resources"

# Cleanup unused images
docker system prune -af

# Check for large logs
du -sh /var/log/containers/*
```

### Networking Issues

#### Pod-to-Pod Communication Fails
```bash
# Test connectivity
kubectl exec <pod-a> -- ping <pod-b-ip>

# Check network policies
kubectl get networkpolicies -n <namespace>

# Verify CNI plugin
kubectl get pods -n kube-system | grep -E "calico|weave|flannel|cilium"
```

### Storage Issues

#### PVC Stuck in Pending
```bash
# Check PVC events
kubectl describe pvc <pvc-name> -n <namespace>

# Verify StorageClass exists
kubectl get storageclass

# Check provisioner pods
kubectl get pods -n kube-system | grep provisioner
```

## Diagnostic Commands Cheat Sheet

```bash
# Cluster overview
kubectl cluster-info
kubectl get componentstatuses

# Resource usage
kubectl top nodes
kubectl top pods -n <namespace>

# Events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Logs
kubectl logs -f <pod> -n <namespace>
kubectl logs -f <pod> -n <namespace> --all-containers

# Exec into pod
kubectl exec -it <pod> -n <namespace> -- /bin/sh

# Port forward
kubectl port-forward <pod> 8080:80 -n <namespace>

# Copy files
kubectl cp <namespace>/<pod>:/path/to/file ./local-file
```
