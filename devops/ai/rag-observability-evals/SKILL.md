---
name: rag-observability-evals
description: Monitor and evaluate RAG systems with retrieval quality metrics, groundedness checks, hallucination detection, and continuous regression testing.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# RAG Observability and Evaluations

Run retrieval-augmented generation like a measurable production system, not a black box.

## What to Measure

### Retrieval Quality
- Recall@k and MRR for top-k chunks
- Citation coverage and source freshness
- Embedding drift and index staleness

### Generation Quality
- Groundedness score (answer supported by retrieved context)
- Hallucination rate by route/use case
- Instruction adherence and format validity

### Reliability and Cost
- p50/p95 latency split by retrieval vs generation
- Token usage per stage
- Cache hit rate and cost per successful answer

## Evaluation Pipeline

1. Curate a benchmark set with gold answers and source docs.
2. Run nightly offline evals for every retriever/model configuration.
3. Execute online shadow evals on sampled production traffic.
4. Gate releases on minimum quality + safety + latency thresholds.

## Alerting Strategy

Page on:
- sharp decline in groundedness,
- spike in unanswered or fallback responses,
- index freshness SLA breach,
- cost-per-answer anomaly.

## Practical Guardrails

- Force citations for high-risk domains.
- Return abstain/fallback when confidence is below threshold.
- Re-rank retrieved chunks before final generation.
- Use query rewriting only with strict regression tests.

## Incident Triage Checklist

- Did embedding model change?
- Did chunking/indexing logic change?
- Did source corpus ingestion fail?
- Did gateway route to unintended model tier?

## Related Skills

- [rag-infrastructure](../../../infrastructure/local-ai/rag-infrastructure/) - Deploy robust RAG backends
- [agent-observability](../agent-observability/) - Instrument requests, traces, and costs
- [agent-evals](../agent-evals/) - Build repeatable eval suites
