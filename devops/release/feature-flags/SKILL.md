---
name: feature-flags
description: Implement feature flags for progressive feature rollout using LaunchDarkly, Unleash, or custom solutions. Control feature visibility, perform A/B testing, and enable trunk-based development. Use when implementing gradual rollouts, feature toggles, or experimentation platforms.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Feature Flags

Control feature releases and enable progressive rollout with feature flag systems.

## When to Use This Skill

Use this skill when:
- Implementing gradual feature rollouts
- Enabling trunk-based development
- Running A/B tests and experiments
- Managing feature lifecycles
- Implementing kill switches for production

## Prerequisites

- Application code access
- Feature flag service or self-hosted solution
- Basic understanding of deployment patterns

## Feature Flag Types

| Type | Purpose | Example |
|------|---------|---------|
| Release | Control feature visibility | New checkout flow |
| Experiment | A/B testing | Button color test |
| Ops | Runtime configuration | Rate limiting |
| Permission | User access control | Premium features |
| Kill Switch | Emergency disable | Third-party integration |

## LaunchDarkly

### SDK Setup (Node.js)

```javascript
const LaunchDarkly = require('launchdarkly-node-server-sdk');

const client = LaunchDarkly.init(process.env.LAUNCHDARKLY_SDK_KEY);

await client.waitForInitialization();

// Evaluate flag
const user = {
  key: 'user-123',
  email: 'user@example.com',
  custom: {
    plan: 'premium',
    company: 'acme'
  }
};

const showNewFeature = await client.variation('new-checkout', user, false);

if (showNewFeature) {
  // New feature code
} else {
  // Existing code
}
```

### React SDK

```javascript
import { withLDProvider, useFlags, useLDClient } from 'launchdarkly-react-client-sdk';

// Provider setup
export default withLDProvider({
  clientSideID: 'your-client-side-id',
  user: {
    key: 'user-123',
    email: 'user@example.com'
  }
})(App);

// Using flags in component
function FeatureComponent() {
  const { newCheckout, experimentVariant } = useFlags();
  const ldClient = useLDClient();

  // Track events
  const handleClick = () => {
    ldClient.track('checkout-started');
  };

  if (newCheckout) {
    return <NewCheckout onClick={handleClick} />;
  }
  return <OldCheckout onClick={handleClick} />;
}
```

### Targeting Rules

```yaml
# LaunchDarkly targeting configuration
flag: new-checkout
targeting:
  # Individual users
  targets:
    - variation: true
      values: ['user-123', 'user-456']
  
  # Rules
  rules:
    # Beta users
    - variation: true
      clauses:
        - attribute: email
          op: endsWith
          values: ['@company.com']
    
    # Premium plan
    - variation: true
      clauses:
        - attribute: plan
          op: in
          values: ['premium', 'enterprise']
    
    # Percentage rollout
    - variation: true
      rollout:
        variations:
          - variation: true
            weight: 20000  # 20%
          - variation: false
            weight: 80000  # 80%
  
  # Default
  fallthrough:
    variation: false
```

## Unleash

### Server Setup

```yaml
# docker-compose.yml
version: '3.8'

services:
  unleash:
    image: unleashorg/unleash-server:latest
    ports:
      - "4242:4242"
    environment:
      - DATABASE_URL=postgres://postgres:password@db/unleash
      - DATABASE_SSL=false
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=unleash
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

### SDK Setup (Node.js)

```javascript
const { initialize } = require('unleash-client');

const unleash = initialize({
  url: 'http://localhost:4242/api',
  appName: 'my-app',
  customHeaders: {
    Authorization: 'your-api-token'
  }
});

unleash.on('ready', () => {
  // Check feature
  const isEnabled = unleash.isEnabled('new-checkout');
  
  // With context
  const context = {
    userId: 'user-123',
    properties: {
      plan: 'premium'
    }
  };
  
  const isEnabledForUser = unleash.isEnabled('new-checkout', context);
  
  // Get variant
  const variant = unleash.getVariant('experiment-flag', context);
  console.log(variant.name); // 'control' or 'treatment'
});
```

### Activation Strategies

```yaml
# Standard strategies
strategies:
  - name: default
    # On/off for everyone
    
  - name: userWithId
    parameters:
      userIds: 'user-1,user-2,user-3'
    
  - name: gradualRolloutUserId
    parameters:
      percentage: 25
      groupId: 'new-feature'
    
  - name: gradualRolloutRandom
    parameters:
      percentage: 50
    
  - name: flexibleRollout
    parameters:
      rollout: 30
      stickiness: userId
      groupId: 'checkout-exp'
```

## Custom Implementation

### Database-Backed Flags

```python
# models.py
from django.db import models

class FeatureFlag(models.Model):
    name = models.CharField(max_length=100, unique=True)
    enabled = models.BooleanField(default=False)
    rollout_percentage = models.IntegerField(default=0)
    allowed_users = models.JSONField(default=list)
    rules = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

# service.py
import hashlib

class FeatureFlagService:
    def __init__(self):
        self._cache = {}
    
    def is_enabled(self, flag_name, user_id=None, context=None):
        flag = self._get_flag(flag_name)
        
        if not flag or not flag.enabled:
            return False
        
        # Check user allowlist
        if user_id and user_id in flag.allowed_users:
            return True
        
        # Check rules
        if context and self._evaluate_rules(flag.rules, context):
            return True
        
        # Check percentage rollout
        if flag.rollout_percentage > 0 and user_id:
            return self._is_in_rollout(flag_name, user_id, flag.rollout_percentage)
        
        return flag.rollout_percentage == 100
    
    def _is_in_rollout(self, flag_name, user_id, percentage):
        hash_input = f"{flag_name}:{user_id}"
        hash_value = int(hashlib.md5(hash_input.encode()).hexdigest(), 16)
        return (hash_value % 100) < percentage
    
    def _evaluate_rules(self, rules, context):
        for rule in rules.get('rules', []):
            if self._evaluate_rule(rule, context):
                return True
        return False
```

### Redis-Backed Flags

```python
import redis
import json

class RedisFeatureFlags:
    def __init__(self, redis_url):
        self.redis = redis.from_url(redis_url)
        self.prefix = 'feature_flag:'
    
    def set_flag(self, name, config):
        key = f"{self.prefix}{name}"
        self.redis.set(key, json.dumps(config))
    
    def is_enabled(self, name, user_id=None):
        key = f"{self.prefix}{name}"
        data = self.redis.get(key)
        
        if not data:
            return False
        
        config = json.loads(data)
        
        if not config.get('enabled', False):
            return False
        
        # User allowlist
        if user_id in config.get('users', []):
            return True
        
        # Percentage rollout
        percentage = config.get('percentage', 0)
        if percentage == 100:
            return True
        
        if percentage > 0 and user_id:
            return self._hash_user(name, user_id) < percentage
        
        return False
    
    def _hash_user(self, flag, user_id):
        import hashlib
        hash_input = f"{flag}:{user_id}"
        return int(hashlib.sha256(hash_input.encode()).hexdigest(), 16) % 100
```

## Testing with Feature Flags

### Unit Testing

```javascript
// Jest mocking
jest.mock('launchdarkly-node-server-sdk', () => ({
  init: jest.fn(() => ({
    waitForInitialization: jest.fn().mockResolvedValue(undefined),
    variation: jest.fn()
  }))
}));

describe('Checkout', () => {
  it('shows new checkout when flag enabled', async () => {
    const ldClient = require('launchdarkly-node-server-sdk').init();
    ldClient.variation.mockResolvedValue(true);
    
    const result = await renderCheckout(user);
    expect(result).toContain('NewCheckout');
  });
  
  it('shows old checkout when flag disabled', async () => {
    const ldClient = require('launchdarkly-node-server-sdk').init();
    ldClient.variation.mockResolvedValue(false);
    
    const result = await renderCheckout(user);
    expect(result).toContain('OldCheckout');
  });
});
```

### Integration Testing

```python
# pytest fixtures
import pytest

@pytest.fixture
def feature_flags():
    """Provide controllable feature flags for testing."""
    flags = {}
    
    class TestFlags:
        def set(self, name, value):
            flags[name] = value
        
        def is_enabled(self, name, **kwargs):
            return flags.get(name, False)
    
    return TestFlags()

def test_new_checkout(feature_flags):
    feature_flags.set('new-checkout', True)
    
    response = client.get('/checkout')
    assert 'new-checkout-form' in response.content
```

## Monitoring and Analytics

### Flag Usage Tracking

```javascript
// Track flag evaluations
const flagMetrics = {
  evaluations: new Map(),
  
  track(flagName, variation, user) {
    const key = `${flagName}:${variation}`;
    const count = this.evaluations.get(key) || 0;
    this.evaluations.set(key, count + 1);
    
    // Send to analytics
    analytics.track('feature_flag_evaluated', {
      flag: flagName,
      variation: variation,
      userId: user.key
    });
  }
};
```

### Stale Flag Detection

```python
from datetime import datetime, timedelta

def detect_stale_flags():
    """Find flags that haven't been evaluated recently."""
    stale_threshold = timedelta(days=30)
    now = datetime.utcnow()
    
    stale_flags = []
    for flag in FeatureFlag.objects.all():
        if flag.last_evaluated:
            age = now - flag.last_evaluated
            if age > stale_threshold:
                stale_flags.append({
                    'name': flag.name,
                    'last_evaluated': flag.last_evaluated,
                    'age_days': age.days
                })
    
    return stale_flags
```

## Common Issues

### Issue: Inconsistent Flag Evaluation
**Problem**: Same user sees different variations
**Solution**: Use consistent hashing, check caching strategy

### Issue: Flag Debt Accumulation
**Problem**: Too many old flags in codebase
**Solution**: Implement flag lifecycle, regular cleanup sprints

### Issue: Performance Impact
**Problem**: Flag evaluation slowing requests
**Solution**: Use local caching, batch evaluations

## Best Practices

- Use consistent naming conventions
- Document flag purpose and owner
- Set expiration dates for temporary flags
- Implement flag lifecycle management
- Use gradual rollouts (not 0→100)
- Monitor flag evaluation metrics
- Clean up old flags regularly
- Test both variations in CI

## Related Skills

- [blue-green-deploy](../blue-green-deploy/) - Deployment strategies
- [git-workflow](../git-workflow/) - Trunk-based development
- [alerting-oncall](../../observability/alerting-oncall/) - Monitoring rollouts
