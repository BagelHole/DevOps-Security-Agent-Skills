---
name: gpu-kubernetes-operations
description: Operate GPU-backed Kubernetes clusters for AI inference and training with scheduling, autoscaling, node health, MIG partitioning, and cost controls.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# GPU Kubernetes Operations

Run resilient and cost-efficient GPU clusters for production AI workloads.

## Key Capabilities

- NVIDIA device plugin and GPU operator lifecycle
- MIG partitioning for multi-workload efficiency
- GPU-aware autoscaling (KEDA/cluster autoscaler)
- Node health checks and proactive remediation

## Cluster Baseline

- Dedicated GPU node pools with taints and tolerations
- Runtime class and driver/toolkit compatibility checks
- Local SSD or high-throughput network storage for model weights
- DCGM metrics exported to Prometheus

## Scheduling Patterns

- Use node affinity by GPU type (A10/L4/A100/H100).
- Separate latency-critical inference from batch training.
- Pin model replicas with anti-affinity for availability.
- Reserve headroom for failover and rolling updates.

## Autoscaling Strategy

- Scale on queue depth + GPU utilization, not CPU alone.
- Warm spare replicas for large model cold-start mitigation.
- Cap burst scaling to avoid quota exhaustion.

## Reliability Checks

- ECC error and Xid monitoring
- GPU memory pressure alerts
- Driver mismatch detection during upgrades
- Pod preemption impact analysis

## Cost Optimization

- Prefer MIG slices for smaller inference services.
- Schedule batch jobs in off-peak windows.
- Route low-priority traffic to cheaper model tiers.

## Related Skills

- [llm-inference-scaling](../llm-inference-scaling/) - Autoscale inference workloads
- [model-serving-kubernetes](../../../devops/orchestration/model-serving-kubernetes/) - Production model serving patterns
- [gpu-server-management](../../servers/gpu-server-management/) - Host-level GPU management fundamentals
