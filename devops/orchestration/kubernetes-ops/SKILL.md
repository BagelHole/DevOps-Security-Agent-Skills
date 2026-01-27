---
name: kubernetes-ops
description: Deploy, scale, and manage Kubernetes workloads. Create deployments, services, and configurations, manage cluster resources, troubleshoot pods, and implement production-ready Kubernetes patterns. Use when working with Kubernetes clusters, K8s deployments, or container orchestration.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Kubernetes Operations

Deploy and manage containerized applications on Kubernetes clusters.

## When to Use This Skill

Use this skill when:
- Deploying applications to Kubernetes
- Managing pods, deployments, and services
- Configuring resource limits and scaling
- Troubleshooting Kubernetes workloads
- Setting up networking and ingress

## Prerequisites

- kubectl installed and configured
- Access to a Kubernetes cluster
- Basic understanding of containers

## Core Resources

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:1.0.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: myapp-secrets
              key: database-url
```

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
---
# LoadBalancer for external access
apiVersion: v1
kind: Service
metadata:
  name: myapp-external
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

### Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 80
```

## Configuration Management

### ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  config.yaml: |
    server:
      port: 8080
    logging:
      level: info
  APP_ENV: production
```

```yaml
# Using ConfigMap
containers:
- name: myapp
  envFrom:
  - configMapRef:
      name: myapp-config
  volumeMounts:
  - name: config
    mountPath: /etc/config
volumes:
- name: config
  configMap:
    name: myapp-config
```

### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
type: Opaque
stringData:
  database-url: postgres://user:pass@host:5432/db
  api-key: secret-key-value
```

```bash
# Create secret from command line
kubectl create secret generic myapp-secrets \
  --from-literal=database-url='postgres://...' \
  --from-file=tls.crt=cert.pem
```

## kubectl Commands

### Resource Management

```bash
# Apply configuration
kubectl apply -f deployment.yaml

# Get resources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get all -n myapp

# Describe resource
kubectl describe pod myapp-xxx

# Delete resource
kubectl delete -f deployment.yaml
kubectl delete pod myapp-xxx

# Edit resource
kubectl edit deployment myapp
```

### Debugging

```bash
# View logs
kubectl logs myapp-xxx
kubectl logs -f myapp-xxx --tail=100
kubectl logs myapp-xxx -c sidecar  # specific container

# Execute command
kubectl exec -it myapp-xxx -- /bin/sh

# Port forward
kubectl port-forward svc/myapp 8080:80
kubectl port-forward pod/myapp-xxx 8080:8080

# View events
kubectl get events --sort-by='.lastTimestamp'

# Debug pod
kubectl debug myapp-xxx -it --image=busybox
```

### Scaling

```bash
# Manual scaling
kubectl scale deployment myapp --replicas=5

# Autoscaling
kubectl autoscale deployment myapp \
  --min=2 --max=10 \
  --cpu-percent=80
```

## Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## Persistent Storage

### PersistentVolumeClaim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myapp-data
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 10Gi
---
# Using PVC
containers:
- name: myapp
  volumeMounts:
  - name: data
    mountPath: /data
volumes:
- name: data
  persistentVolumeClaim:
    claimName: myapp-data
```

## StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

## Jobs and CronJobs

### Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: migration
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: myapp:1.0.0
        command: ["./migrate.sh"]
      restartPolicy: Never
  backoffLimit: 3
```

### CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:latest
            command: ["./backup.sh"]
          restartPolicy: OnFailure
```

## Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: myapp-network-policy
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
```

## Resource Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: myapp-quota
  namespace: myapp
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    pods: "20"
```

## Rolling Updates

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

```bash
# Update image
kubectl set image deployment/myapp myapp=myapp:2.0.0

# Check rollout status
kubectl rollout status deployment/myapp

# View history
kubectl rollout history deployment/myapp

# Rollback
kubectl rollout undo deployment/myapp
kubectl rollout undo deployment/myapp --to-revision=2
```

## Common Issues

### Issue: Pod Stuck in Pending
**Problem**: Pod won't start
**Solution**: Check resource availability, node selector, PVC binding

```bash
kubectl describe pod myapp-xxx
kubectl get events
```

### Issue: CrashLoopBackOff
**Problem**: Container keeps restarting
**Solution**: Check logs, verify entrypoint, check probes

```bash
kubectl logs myapp-xxx --previous
kubectl describe pod myapp-xxx
```

### Issue: Service Not Accessible
**Problem**: Cannot connect to service
**Solution**: Check selector labels, verify endpoints exist

```bash
kubectl get endpoints myapp
kubectl describe svc myapp
```

### Issue: Image Pull Error
**Problem**: ImagePullBackOff
**Solution**: Check image name, verify registry credentials

```bash
kubectl create secret docker-registry regcred \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=pass
```

## Best Practices

- Always set resource requests and limits
- Implement liveness and readiness probes
- Use namespaces for isolation
- Apply network policies for security
- Use ConfigMaps and Secrets for configuration
- Implement pod disruption budgets for availability
- Use labels consistently for organization
- Enable RBAC for access control

## Related Skills

- [helm-charts](../helm-charts/) - Package management
- [argocd-gitops](../argocd-gitops/) - GitOps deployments
- [kubernetes-hardening](../../../security/hardening/kubernetes-hardening/) - Security
