---
name: ai-inference-service-mesh
description: Use service mesh patterns for AI inference traffic management, mTLS, canary releases, policy enforcement, and cross-cluster resilience.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AI Inference Service Mesh

Apply Istio/Linkerd mesh controls to secure and optimize east-west AI traffic across inference microservices.

## Why Mesh for AI

- Enforce mTLS between gateway, retriever, reranker, and model services
- Apply fine-grained traffic policies without app code changes
- Run progressive delivery for model-serving backends
- Observe latency hops for retrieval + generation chains

## Core Patterns

### Security
- mTLS strict mode cluster-wide
- AuthorizationPolicy per service account
- Egress policies for approved model endpoints only

### Traffic Management
- Canary by header or percentage for new model versions
- Retry budgets tuned for long-running streaming requests
- Circuit breakers to protect overloaded inference backends

### Resilience
- Outlier detection on failing pods
- Locality-aware routing in multi-zone clusters
- Failover to secondary cluster/provider

## Observability

- Capture distributed traces across the full AI request path
- Emit service-level and route-level p95/p99 latency
- Segment metrics by model and tenant labels

## Pitfalls to Avoid

- Aggressive timeouts that break streaming responses
- Blanket retries that amplify expensive generation calls
- Missing identity boundaries between tenant-facing and internal services

## Related Skills

- [service-mesh](../service-mesh/) - Foundational mesh concepts
- [llm-gateway](../llm-gateway/) - North-south API gateway controls
- [opentelemetry](../../../devops/observability/opentelemetry/) - End-to-end tracing and metrics
