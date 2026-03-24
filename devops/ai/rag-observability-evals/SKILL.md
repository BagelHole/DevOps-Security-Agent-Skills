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

## When to Use This Skill

- Deploying a RAG system to production and need quality monitoring
- Setting up automated evaluation pipelines for retrieval and generation
- Debugging hallucination or relevance regressions
- Building dashboards for RAG-specific golden signals
- Establishing quality gates for RAG pipeline changes

## Prerequisites

- RAG pipeline with instrumented retrieval and generation stages
- Python 3.10+ with evaluation libraries (ragas, langchain, openai)
- Prometheus endpoint for custom metrics export
- Benchmark dataset with gold-standard question/answer/source triples
- OpenTelemetry SDK integrated into the RAG service

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

## RAGAS Evaluation Script

```python
# rag_eval.py
"""Evaluate RAG pipeline quality using RAGAS metrics."""
from ragas import evaluate
from ragas.metrics import (
    faithfulness,
    answer_relevancy,
    context_precision,
    context_recall,
    context_entity_recall,
    answer_similarity,
)
from datasets import Dataset
import json
import sys

def load_eval_dataset(path: str) -> Dataset:
    """Load evaluation dataset with required columns."""
    with open(path) as f:
        data = json.load(f)

    return Dataset.from_dict({
        "question": [d["question"] for d in data],
        "answer": [d["generated_answer"] for d in data],
        "contexts": [d["retrieved_contexts"] for d in data],
        "ground_truth": [d["reference_answer"] for d in data],
    })

def run_evaluation(dataset_path: str, output_path: str):
    """Run full RAGAS evaluation suite."""
    dataset = load_eval_dataset(dataset_path)

    metrics = [
        faithfulness,
        answer_relevancy,
        context_precision,
        context_recall,
        context_entity_recall,
        answer_similarity,
    ]

    results = evaluate(dataset, metrics=metrics)

    # Print summary
    print("=== RAG Evaluation Results ===")
    for metric_name, score in results.items():
        print(f"  {metric_name}: {score:.4f}")

    # Save detailed results
    with open(output_path, "w") as f:
        json.dump({
            "summary": {k: float(v) for k, v in results.items()},
            "dataset_size": len(dataset),
        }, f, indent=2)

    return results

if __name__ == "__main__":
    run_evaluation(sys.argv[1], sys.argv[2])
```

## Groundedness Scoring

```python
# groundedness.py
"""Score whether generated answers are grounded in retrieved context."""
from openai import OpenAI
import json
from typing import List

client = OpenAI()

GROUNDEDNESS_PROMPT = """You are evaluating whether an AI answer is fully grounded
in the provided context documents. Score each claim in the answer.

Context documents:
{contexts}

Answer to evaluate:
{answer}

For each distinct claim in the answer, determine:
1. SUPPORTED - the claim is directly supported by the context
2. PARTIALLY_SUPPORTED - the claim is partially supported
3. NOT_SUPPORTED - the claim has no support in the context

Return JSON:
{{
  "claims": [
    {{"claim": "...", "verdict": "SUPPORTED|PARTIALLY_SUPPORTED|NOT_SUPPORTED", "evidence": "..."}}
  ],
  "groundedness_score": <float 0-1>,
  "unsupported_claims": ["..."]
}}
"""

def score_groundedness(answer: str, contexts: List[str]) -> dict:
    """Score groundedness of a single answer against its contexts."""
    context_text = "\n---\n".join(
        f"[Document {i+1}]: {c}" for i, c in enumerate(contexts)
    )

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": GROUNDEDNESS_PROMPT.format(
                contexts=context_text, answer=answer
            ),
        }],
        response_format={"type": "json_object"},
        temperature=0,
    )

    return json.loads(response.choices[0].message.content)

def batch_groundedness(eval_data: list) -> dict:
    """Score groundedness for a batch of QA pairs."""
    scores = []
    unsupported_count = 0
    total_claims = 0

    for item in eval_data:
        result = score_groundedness(
            item["generated_answer"],
            item["retrieved_contexts"],
        )
        scores.append(result["groundedness_score"])
        unsupported_count += len(result["unsupported_claims"])
        total_claims += len(result["claims"])

    avg_score = sum(scores) / len(scores) if scores else 0
    return {
        "average_groundedness": avg_score,
        "total_claims": total_claims,
        "unsupported_claims": unsupported_count,
        "unsupported_rate": unsupported_count / total_claims if total_claims else 0,
        "sample_count": len(eval_data),
    }
```

## Retrieval Quality Metrics

```python
# retrieval_metrics.py
"""Compute retrieval quality metrics for RAG evaluation."""
from typing import List, Set
import numpy as np

def recall_at_k(
    retrieved_ids: List[str],
    relevant_ids: Set[str],
    k: int
) -> float:
    """Compute Recall@K for a single query."""
    top_k = set(retrieved_ids[:k])
    if not relevant_ids:
        return 0.0
    return len(top_k & relevant_ids) / len(relevant_ids)

def mrr(
    retrieved_ids: List[str],
    relevant_ids: Set[str]
) -> float:
    """Compute Mean Reciprocal Rank for a single query."""
    for i, doc_id in enumerate(retrieved_ids):
        if doc_id in relevant_ids:
            return 1.0 / (i + 1)
    return 0.0

def ndcg_at_k(
    retrieved_ids: List[str],
    relevant_ids: Set[str],
    k: int
) -> float:
    """Compute NDCG@K for a single query."""
    dcg = 0.0
    for i, doc_id in enumerate(retrieved_ids[:k]):
        if doc_id in relevant_ids:
            dcg += 1.0 / np.log2(i + 2)

    ideal_dcg = sum(1.0 / np.log2(i + 2) for i in range(min(len(relevant_ids), k)))
    return dcg / ideal_dcg if ideal_dcg > 0 else 0.0

def compute_retrieval_metrics(
    queries: list,
    k_values: list = [1, 3, 5, 10]
) -> dict:
    """Compute aggregate retrieval metrics across all queries."""
    results = {}
    for k in k_values:
        recalls = [
            recall_at_k(q["retrieved_ids"], set(q["relevant_ids"]), k)
            for q in queries
        ]
        mrrs = [mrr(q["retrieved_ids"], set(q["relevant_ids"])) for q in queries]
        ndcgs = [
            ndcg_at_k(q["retrieved_ids"], set(q["relevant_ids"]), k)
            for q in queries
        ]
        results[f"recall@{k}"] = np.mean(recalls)
        results[f"ndcg@{k}"] = np.mean(ndcgs)

    results["mrr"] = np.mean(mrrs)
    return results
```

## Prometheus Metrics Export

```python
# rag_metrics_exporter.py
"""Export RAG quality metrics to Prometheus."""
from prometheus_client import Histogram, Counter, Gauge, start_http_server
import time

# Latency histograms by stage
RETRIEVAL_LATENCY = Histogram(
    "rag_retrieval_duration_seconds",
    "Time spent in retrieval stage",
    ["index_name", "retriever_type"],
    buckets=[0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0],
)

GENERATION_LATENCY = Histogram(
    "rag_generation_duration_seconds",
    "Time spent in generation stage",
    ["model", "route"],
    buckets=[0.5, 1.0, 2.0, 5.0, 10.0, 30.0],
)

RERANKING_LATENCY = Histogram(
    "rag_reranking_duration_seconds",
    "Time spent in reranking stage",
    ["reranker_model"],
    buckets=[0.05, 0.1, 0.25, 0.5, 1.0],
)

# Quality gauges (updated from offline evals)
GROUNDEDNESS_SCORE = Gauge(
    "rag_groundedness_score",
    "Latest groundedness evaluation score",
    ["route", "model"],
)

FAITHFULNESS_SCORE = Gauge(
    "rag_faithfulness_score",
    "Latest faithfulness evaluation score",
    ["route", "model"],
)

CONTEXT_PRECISION = Gauge(
    "rag_context_precision_score",
    "Latest context precision score",
    ["route", "index_name"],
)

RECALL_AT_K = Gauge(
    "rag_recall_at_k",
    "Recall@K for retrieval",
    ["k", "index_name"],
)

# Operational counters
REQUESTS_TOTAL = Counter(
    "rag_requests_total",
    "Total RAG requests",
    ["route", "status"],
)

HALLUCINATION_DETECTED = Counter(
    "rag_hallucination_detected_total",
    "Detected hallucinations",
    ["route", "severity"],
)

FALLBACK_TRIGGERED = Counter(
    "rag_fallback_triggered_total",
    "Times RAG fell back to abstain/default",
    ["route", "reason"],
)

TOKENS_USED = Counter(
    "rag_tokens_used_total",
    "Tokens consumed by stage",
    ["stage", "model"],
)

CACHE_HITS = Counter(
    "rag_cache_hits_total",
    "Semantic cache hits",
    ["cache_type"],
)

# Index health
INDEX_STALENESS_SECONDS = Gauge(
    "rag_index_staleness_seconds",
    "Seconds since last index update",
    ["index_name"],
)

INDEX_DOCUMENT_COUNT = Gauge(
    "rag_index_document_count",
    "Number of documents in index",
    ["index_name"],
)

def start_metrics_server(port: int = 9090):
    """Start Prometheus metrics HTTP server."""
    start_http_server(port)
    print(f"RAG metrics server running on :{port}/metrics")
```

## Evaluation Pipeline

1. Curate a benchmark set with gold answers and source docs.
2. Run nightly offline evals for every retriever/model configuration.
3. Execute online shadow evals on sampled production traffic.
4. Gate releases on minimum quality + safety + latency thresholds.

```yaml
# eval-pipeline-cron.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: rag-nightly-eval
  namespace: ai-evals
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: eval-runner
              image: registry.internal/rag-eval:latest
              command:
                - python
                - -m
                - rag_eval
                - --dataset=/data/benchmark_v3.json
                - --output=/results/nightly-$(date +%Y%m%d).json
                - --push-metrics
                - --fail-on-regression
              env:
                - name: PROMETHEUS_PUSHGATEWAY
                  value: "http://pushgateway:9091"
                - name: MLFLOW_TRACKING_URI
                  value: "http://mlflow:5000"
              volumeMounts:
                - name: eval-data
                  mountPath: /data
                - name: results
                  mountPath: /results
          volumes:
            - name: eval-data
              persistentVolumeClaim:
                claimName: eval-benchmark-data
            - name: results
              persistentVolumeClaim:
                claimName: eval-results
          restartPolicy: OnFailure
```

## Alerting Strategy

```yaml
# rag-alerts.yaml
groups:
  - name: rag-quality-alerts
    rules:
      - alert: GroundednessDropped
        expr: rag_groundedness_score < 0.75
        for: 10m
        labels:
          severity: sev2
        annotations:
          summary: "Groundedness score dropped below 0.75 for {{ $labels.route }}"

      - alert: HallucinationSpike
        expr: |
          rate(rag_hallucination_detected_total[15m])
          / rate(rag_requests_total[15m]) > 0.10
        for: 5m
        labels:
          severity: sev1

      - alert: IndexStale
        expr: rag_index_staleness_seconds > 86400
        for: 5m
        labels:
          severity: sev3
        annotations:
          summary: "Index {{ $labels.index_name }} not updated in 24h"

      - alert: HighFallbackRate
        expr: |
          rate(rag_fallback_triggered_total[10m])
          / rate(rag_requests_total[10m]) > 0.20
        for: 10m
        labels:
          severity: sev2

      - alert: RetrievalLatencyHigh
        expr: |
          histogram_quantile(0.95,
            rate(rag_retrieval_duration_seconds_bucket[5m])
          ) > 2.0
        for: 5m
        labels:
          severity: sev2
```

## Practical Guardrails

- Force citations for high-risk domains.
- Return abstain/fallback when confidence is below threshold.
- Re-rank retrieved chunks before final generation.
- Use query rewriting only with strict regression tests.

## Incident Triage Checklist

| Symptom | Check First | Check Second |
|---------|-------------|--------------|
| Groundedness dropped | Embedding model change? | Chunking/indexing logic change? |
| Retrieval returning irrelevant docs | Index freshness and document count | Embedding model version mismatch |
| Latency spike in retrieval | Vector DB connection pool and load | Index size growth beyond threshold |
| Cost per answer increasing | Token usage per stage breakdown | Cache hit rate decline |
| Hallucination spike | Model version or temperature change | Context window overflow (truncated docs) |

## Troubleshooting

| Issue | Diagnosis | Resolution |
|-------|-----------|------------|
| RAGAS eval returns 0 for all metrics | Check dataset format matches expected schema | Ensure contexts are lists, not strings |
| Groundedness score unreliable | LLM judge inconsistency | Increase judge sample size, set temperature=0 |
| Index staleness alert firing | Ingestion pipeline failure | Check data source connectivity and ingestion logs |
| Retrieval recall dropping | Embedding drift after model update | Re-index corpus with current embedding model |
| High latency in generation | Context too large for model | Reduce top-k or add summarization step |

## Related Skills

- [rag-infrastructure](../../../infrastructure/local-ai/rag-infrastructure/) - Deploy robust RAG backends
- [agent-observability](../agent-observability/) - Instrument requests, traces, and costs
- [agent-evals](../agent-evals/) - Build repeatable eval suites
- [ai-sre-incident-response](../ai-sre-incident-response/) - Incident response for quality regressions
- [opentelemetry](../../observability/opentelemetry/) - Distributed tracing for RAG pipelines
