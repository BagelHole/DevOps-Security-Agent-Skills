---
name: blue-green-deploy
description: Configure zero-downtime deployment strategies including blue-green, canary, and rolling deployments. Implement traffic shifting, health checks, and rollback procedures. Use when implementing production deployment strategies or zero-downtime releases.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Blue-Green & Deployment Strategies

Implement zero-downtime deployment patterns for production systems.

## When to Use This Skill

Use this skill when:
- Implementing zero-downtime deployments
- Reducing deployment risk
- Enabling instant rollbacks
- Running canary releases
- Performing A/B testing in production

## Prerequisites

- Load balancer or ingress controller
- Container orchestration (K8s) or cloud platform
- CI/CD pipeline
- Health check endpoints

## Deployment Strategy Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT STRATEGIES                     │
├─────────────┬─────────────┬─────────────┬──────────────────┤
│  Blue-Green │   Canary    │   Rolling   │    Recreate      │
├─────────────┼─────────────┼─────────────┼──────────────────┤
│ Full env    │ Gradual %   │ Pod by pod  │ All at once      │
│ swap        │ rollout     │ replacement │                  │
├─────────────┼─────────────┼─────────────┼──────────────────┤
│ Instant     │ Slow, safe  │ Moderate    │ Fast, risky      │
│ rollback    │ rollback    │ rollback    │                  │
├─────────────┼─────────────┼─────────────┼──────────────────┤
│ 2x resources│ +10-25%     │ Same        │ Same             │
│ needed      │ resources   │ resources   │                  │
└─────────────┴─────────────┴─────────────┴──────────────────┘
```

## Blue-Green Deployment

### Concept

```
Before:
┌─────────┐     ┌───────────────┐
│  Users  │────▶│  Blue (v1)    │ ◀── Active
└─────────┘     └───────────────┘
                ┌───────────────┐
                │  Green (v2)   │ ◀── Staging
                └───────────────┘

After Switch:
┌─────────┐     ┌───────────────┐
│  Users  │     │  Blue (v1)    │ ◀── Standby
└─────────┘     └───────────────┘
      │         ┌───────────────┐
      └────────▶│  Green (v2)   │ ◀── Active
                └───────────────┘
```

### Kubernetes Implementation

```yaml
# blue-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-blue
  labels:
    app: myapp
    version: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: myapp
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
---
# green-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-green
  labels:
    app: myapp
    version: green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: myapp
        image: myapp:v2.0.0
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
---
# service.yaml - Switch by changing selector
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
    version: blue  # Change to 'green' to switch
  ports:
  - port: 80
    targetPort: 8080
```

### Switch Script

```bash
#!/bin/bash
# blue-green-switch.sh

CURRENT=$(kubectl get svc myapp -o jsonpath='{.spec.selector.version}')
NEW_VERSION=$1

echo "Current version: $CURRENT"
echo "Switching to: $NEW_VERSION"

# Verify new deployment is ready
kubectl rollout status deployment/myapp-$NEW_VERSION

# Check health
HEALTH=$(kubectl exec -it deployment/myapp-$NEW_VERSION -- curl -s localhost:8080/health)
if [ "$HEALTH" != "ok" ]; then
  echo "Health check failed"
  exit 1
fi

# Switch traffic
kubectl patch svc myapp -p "{\"spec\":{\"selector\":{\"version\":\"$NEW_VERSION\"}}}"

echo "Switched to $NEW_VERSION"
```

### AWS ECS Blue-Green

```yaml
# AWS CodeDeploy appspec.yml
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "arn:aws:ecs:region:account:task-definition/myapp:2"
        LoadBalancerInfo:
          ContainerName: "myapp"
          ContainerPort: 8080
Hooks:
  - BeforeInstall: "LambdaFunctionToValidateBeforeTrafficShift"
  - AfterInstall: "LambdaFunctionToValidateAfterTrafficShift"
  - AfterAllowTestTraffic: "LambdaFunctionToValidateTestTraffic"
  - BeforeAllowTraffic: "LambdaFunctionToValidateBeforeAllowTraffic"
  - AfterAllowTraffic: "LambdaFunctionToValidateAfterAllowTraffic"
```

## Canary Deployment

### Kubernetes with Istio

```yaml
# VirtualService for traffic splitting
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - match:
    - headers:
        x-canary:
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
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: myapp
spec:
  host: myapp
  subsets:
  - name: stable
    labels:
      version: stable
  - name: canary
    labels:
      version: canary
```

### Argo Rollouts

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 10
      - pause: {duration: 5m}
      - setWeight: 25
      - pause: {duration: 5m}
      - setWeight: 50
      - pause: {duration: 5m}
      - setWeight: 75
      - pause: {duration: 5m}
      analysis:
        templates:
        - templateName: success-rate
        startingStep: 2
        args:
        - name: service-name
          value: myapp
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
        image: myapp:v2.0.0
        ports:
        - containerPort: 8080
---
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
  - name: service-name
  metrics:
  - name: success-rate
    interval: 1m
    successCondition: result[0] >= 0.95
    failureLimit: 3
    provider:
      prometheus:
        address: http://prometheus:9090
        query: |
          sum(rate(http_requests_total{service="{{args.service-name}}",status=~"2.*"}[5m]))
          /
          sum(rate(http_requests_total{service="{{args.service-name}}"}[5m]))
```

## Rolling Deployment

### Kubernetes Default

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Max pods above desired
      maxUnavailable: 0   # Max pods unavailable
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
        image: myapp:v2.0.0
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
```

### Rolling Update Commands

```bash
# Update image
kubectl set image deployment/myapp myapp=myapp:v2.0.0

# Watch rollout
kubectl rollout status deployment/myapp

# Pause rollout
kubectl rollout pause deployment/myapp

# Resume rollout
kubectl rollout resume deployment/myapp

# Rollback
kubectl rollout undo deployment/myapp

# Rollback to specific revision
kubectl rollout undo deployment/myapp --to-revision=2

# View history
kubectl rollout history deployment/myapp
```

## Health Checks

### Comprehensive Health Endpoint

```python
# Flask health endpoint
from flask import Flask, jsonify
import psycopg2
import redis

app = Flask(__name__)

@app.route('/health')
def health():
    """Liveness probe - is the app running?"""
    return jsonify({'status': 'healthy'}), 200

@app.route('/ready')
def ready():
    """Readiness probe - can the app serve traffic?"""
    checks = {}
    
    # Database check
    try:
        conn = psycopg2.connect(DATABASE_URL)
        conn.close()
        checks['database'] = 'ok'
    except Exception as e:
        checks['database'] = str(e)
        return jsonify({'status': 'unhealthy', 'checks': checks}), 503
    
    # Redis check
    try:
        r = redis.from_url(REDIS_URL)
        r.ping()
        checks['redis'] = 'ok'
    except Exception as e:
        checks['redis'] = str(e)
        return jsonify({'status': 'unhealthy', 'checks': checks}), 503
    
    return jsonify({'status': 'healthy', 'checks': checks}), 200
```

## Rollback Procedures

### Automated Rollback

```bash
#!/bin/bash
# auto-rollback.sh

DEPLOYMENT=$1
THRESHOLD=0.95
INTERVAL=60

echo "Monitoring deployment $DEPLOYMENT"

while true; do
  # Get success rate from Prometheus
  SUCCESS_RATE=$(curl -s "http://prometheus:9090/api/v1/query?query=sum(rate(http_requests_total{status=~\"2.*\"}[5m]))/sum(rate(http_requests_total[5m]))" | jq -r '.data.result[0].value[1]')
  
  echo "Current success rate: $SUCCESS_RATE"
  
  if (( $(echo "$SUCCESS_RATE < $THRESHOLD" | bc -l) )); then
    echo "Success rate below threshold! Rolling back..."
    kubectl rollout undo deployment/$DEPLOYMENT
    exit 1
  fi
  
  sleep $INTERVAL
done
```

### Manual Rollback Checklist

```markdown
## Rollback Checklist

### Before Rollback
- [ ] Confirm issue is deployment-related
- [ ] Document current error rates
- [ ] Notify team in #deployments channel

### During Rollback
- [ ] Execute rollback command
- [ ] Monitor rollback progress
- [ ] Verify old version is serving traffic

### After Rollback
- [ ] Confirm error rates normalized
- [ ] Update incident ticket
- [ ] Schedule post-mortem
```

## Common Issues

### Issue: Slow Deployments
**Problem**: Rollout takes too long
**Solution**: Increase maxSurge, decrease minReadySeconds

### Issue: Failed Health Checks
**Problem**: Pods not becoming ready
**Solution**: Check probe endpoints, increase timeouts

### Issue: Traffic During Rollback
**Problem**: Errors during switch
**Solution**: Use connection draining, implement graceful shutdown

## Best Practices

- Always implement health checks
- Use connection draining
- Test rollback procedures regularly
- Monitor key metrics during deployment
- Implement circuit breakers
- Use deployment slots/environments
- Automate deployment verification
- Document rollback procedures

## Related Skills

- [kubernetes-ops](../../orchestration/kubernetes-ops/) - K8s deployment basics
- [argocd-gitops](../../orchestration/argocd-gitops/) - GitOps deployments
- [feature-flags](../feature-flags/) - Progressive rollout
