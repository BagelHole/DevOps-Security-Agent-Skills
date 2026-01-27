---
name: business-continuity
description: Develop business continuity plans and impact analysis. Implement BCP testing and communication procedures. Use when building organizational resilience.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Business Continuity Planning

Develop and maintain business continuity capabilities.

## BCP Framework

```yaml
bcp_phases:
  1_analysis:
    - Business Impact Analysis (BIA)
    - Risk assessment
    - Critical process identification
    
  2_planning:
    - Recovery strategies
    - Resource requirements
    - Communication plans
    
  3_implementation:
    - Procedure documentation
    - Training
    - Technology setup
    
  4_testing:
    - Plan exercises
    - Gap identification
    - Continuous improvement
```

## Business Impact Analysis

```yaml
process_classification:
  critical:
    max_downtime: 4 hours
    examples: Payment processing, authentication
    
  essential:
    max_downtime: 24 hours
    examples: Customer support, reporting
    
  necessary:
    max_downtime: 72 hours
    examples: Internal tools, analytics
    
  desirable:
    max_downtime: 7 days
    examples: Development environments
```

## Communication Plan

```yaml
communication:
  internal:
    - Executive notification
    - Team communication
    - Status updates
    
  external:
    - Customer notification
    - Regulatory reporting
    - Media relations
    
  channels:
    - Primary: Slack/Teams
    - Secondary: Email
    - Emergency: Phone tree
```

## Best Practices

- Annual BIA updates
- Regular plan testing
- Clear roles and responsibilities
- Multiple communication channels
- Executive sponsorship
