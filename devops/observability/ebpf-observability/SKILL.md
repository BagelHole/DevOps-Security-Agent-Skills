---
name: ebpf-observability
description: Use eBPF for deep kernel-level observability — trace syscalls, network flows, and application behavior without code changes using Cilium, Tetragon, and bpftrace.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# eBPF Observability

eBPF (extended Berkeley Packet Filter) allows you to run sandboxed programs in the Linux kernel without modifying kernel source code or loading kernel modules. This skill covers using eBPF for deep observability, network monitoring, and security enforcement across cloud-native infrastructure.

---

## 1. When to Use

Use eBPF-based observability when you need:

- **Deep performance debugging** -- trace kernel-level latency, syscall overhead, and scheduling delays that application-level metrics cannot reveal.
- **Network observability without sidecars** -- capture L3/L4/L7 flows, DNS queries, and TCP state transitions directly from the kernel, eliminating the CPU and memory overhead of sidecar proxies.
- **Security monitoring at the kernel boundary** -- detect container escapes, unexpected process execution, sensitive file access, and anomalous syscall patterns in real time.
- **Continuous profiling in production** -- generate CPU flame graphs and memory allocation profiles with negligible overhead (typically under 1% CPU).
- **Service mesh replacement or augmentation** -- Cilium can replace kube-proxy and provide identity-aware network policies enforced at the kernel level.

Avoid eBPF when your kernel version is below 4.19, when you are running on managed platforms that restrict BPF capabilities, or when your debugging needs are fully met by application-level tracing.

---

## 2. Prerequisites

### Kernel Version Requirements

| Feature                  | Minimum Kernel | Recommended Kernel |
|--------------------------|----------------|--------------------|
| Basic BPF maps & probes  | 4.9            | 5.10+              |
| BPF CO-RE (BTF support)  | 5.2            | 5.10+              |
| BPF ring buffer          | 5.8            | 5.10+              |
| BPF LSM hooks            | 5.7            | 5.15+              |
| Cilium full features     | 4.19           | 5.10+              |
| Tetragon                 | 4.19           | 5.13+              |

### Verify Kernel Support

```bash
# Check kernel version
uname -r

# Verify BTF (BPF Type Format) is enabled -- required for CO-RE
ls /sys/kernel/btf/vmlinux

# Check BPF filesystem is mounted
mount | grep bpf

# If not mounted, mount it
sudo mount -t bpf bpf /sys/fs/bpf

# Verify BPF JIT is enabled
cat /proc/sys/net/core/bpf_jit_enable
# Should return 1; if not:
sudo sysctl net.core.bpf_jit_enable=1
```

### Install Toolchain

```bash
# Ubuntu/Debian -- install bpftrace, bcc tools, and libbpf
sudo apt-get update
sudo apt-get install -y bpftrace bpfcc-tools libbpf-dev linux-headers-$(uname -r)

# Fedora/RHEL
sudo dnf install -y bpftrace bcc-tools libbpf-devel kernel-devel

# Verify bpftrace works
sudo bpftrace -e 'BEGIN { printf("eBPF is working\n"); exit(); }'
```

---

## 3. Cilium Setup

Cilium replaces kube-proxy with eBPF-based networking, providing identity-aware security and deep network observability via Hubble.

### Install Cilium on Kubernetes

```bash
# Add the Cilium Helm repo
helm repo add cilium https://helm.cilium.io/
helm repo update

# Install Cilium with Hubble enabled
helm install cilium cilium/cilium --version 1.16.4 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost="${API_SERVER_IP}" \
  --set k8sServicePort="${API_SERVER_PORT}" \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.metrics.enableOpenMetrics=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload}"

# Wait for Cilium to be ready
cilium status --wait
```

### Install the Cilium CLI and Hubble CLI

```bash
# Cilium CLI
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
curl -L --remote-name "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz"
sudo tar xzvf cilium-linux-amd64.tar.gz -C /usr/local/bin
rm cilium-linux-amd64.tar.gz

# Hubble CLI
HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
curl -L --remote-name "https://github.com/cilium/hubble/releases/download/${HUBBLE_VERSION}/hubble-linux-amd64.tar.gz"
sudo tar xzvf hubble-linux-amd64.tar.gz -C /usr/local/bin
rm hubble-linux-amd64.tar.gz
```

### Hubble Network Observability

```bash
# Port-forward the Hubble Relay
cilium hubble port-forward &

# Observe all flows in real time
hubble observe --follow

# Filter flows by namespace
hubble observe --namespace production --follow

# Filter by verdict (dropped traffic)
hubble observe --verdict DROPPED --follow

# Filter by DNS queries
hubble observe --protocol DNS --follow

# Filter HTTP traffic to a specific service
hubble observe --to-label "app=api-server" --protocol HTTP --follow

# Export flows as JSON for ingestion into SIEM
hubble observe --output json --last 1000 > flows.json
```

### Hubble UI Access

```bash
# Port-forward the Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 12000:80

# Access at http://localhost:12000 -- provides a real-time service dependency map
```

---

## 4. Tetragon for Security

Tetragon is Cilium's runtime security enforcement engine. It uses eBPF to observe and enforce security policies at the kernel level with zero application changes.

### Install Tetragon

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install tetragon cilium/tetragon \
  --namespace kube-system \
  --set tetragon.grpc.enabled=true \
  --set tetragon.exportFilename=/var/run/cilium/tetragon/tetragon.log

# Install the tetra CLI
curl -LO "https://github.com/cilium/tetragon/releases/latest/download/tetra-linux-amd64.tar.gz"
sudo tar xzvf tetra-linux-amd64.tar.gz -C /usr/local/bin
rm tetra-linux-amd64.tar.gz
```

### Process Execution Monitoring

```yaml
# process-monitor.yaml -- TracingPolicy to monitor all process executions
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: process-execution-monitor
spec:
  kprobes: []
  tracepoints: []
  uprobes: []
  enforcers: []
  # process_exec and process_exit events are always emitted by default
  # Use tetra CLI to observe them:
```

```bash
# Watch all process executions cluster-wide
kubectl exec -n kube-system ds/tetragon -c tetragon -- tetra getevents -o compact --process-exec

# Filter to a specific namespace
kubectl exec -n kube-system ds/tetragon -c tetragon -- tetra getevents -o compact \
  --namespace production
```

### File Access Tracking

```yaml
# file-access-policy.yaml -- detect reads/writes to sensitive files
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: sensitive-file-access
spec:
  kprobes:
    - call: "security_file_open"
      syscall: false
      args:
        - index: 0
          type: "file"
      selectors:
        - matchArgs:
            - index: 0
              operator: "Prefix"
              values:
                - "/etc/shadow"
                - "/etc/passwd"
                - "/etc/kubernetes/pki"
                - "/var/run/secrets/kubernetes.io"
                - "/root/.ssh"
```

```bash
kubectl apply -f file-access-policy.yaml

# Observe file access events
kubectl exec -n kube-system ds/tetragon -c tetragon -- tetra getevents -o compact \
  | grep "sensitive-file-access"
```

### Network Connection Enforcement

```yaml
# restrict-egress.yaml -- block unexpected outbound connections
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: restrict-egress-connections
spec:
  kprobes:
    - call: "tcp_connect"
      syscall: false
      args:
        - index: 0
          type: "sock"
      selectors:
        - matchArgs:
            - index: 0
              operator: "DAddr"
              values:
                - "169.254.169.254"  # Block IMDS access
          matchActions:
            - action: Sigkill
        - matchNamespaces:
            - namespace: Mnt
              operator: NotIn
              values:
                - "host_mnt"
```

```bash
kubectl apply -f restrict-egress.yaml
```

### Privileged Escalation Detection

```yaml
# detect-privilege-escalation.yaml
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: detect-privilege-escalation
spec:
  kprobes:
    - call: "__x64_sys_setuid"
      syscall: true
      args:
        - index: 0
          type: "int"
      selectors:
        - matchArgs:
            - index: 0
              operator: "Equal"
              values:
                - "0"
          matchActions:
            - action: Post
              rateLimit: "1m"
    - call: "__x64_sys_setns"
      syscall: true
      args:
        - index: 1
          type: "int"
      selectors:
        - matchActions:
            - action: Post
```

```bash
kubectl apply -f detect-privilege-escalation.yaml
```

---

## 5. bpftrace One-Liners

These are practical bpftrace commands you can run directly in production for targeted debugging.

### Syscall Latency

```bash
# Trace read() syscall latency distribution (microseconds)
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_read { @start[tid] = nsecs; }
  tracepoint:syscalls:sys_exit_read /@start[tid]/ {
    @usecs = hist((nsecs - @start[tid]) / 1000);
    delete(@start[tid]);
  }'

# Top 10 slowest syscalls by total time
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @start[tid] = nsecs; }
  tracepoint:raw_syscalls:sys_exit /@start[tid]/ {
    @ns[probe] = sum(nsecs - @start[tid]);
    delete(@start[tid]);
  } END { print(@ns, 10); }'
```

### DNS Tracing

```bash
# Trace DNS queries via UDP port 53 sends
sudo bpftrace -e 'kprobe:udp_sendmsg {
    $sk = (struct sock *)arg0;
    $dport = ($sk->__sk_common.skc_dport >> 8) | (($sk->__sk_common.skc_dport & 0xff) << 8);
    if ($dport == 53) {
      printf("%-8d %-16s DNS query to %s\n", pid, comm,
        ntop($sk->__sk_common.skc_daddr));
    }
  }'

# Count DNS queries by source process
sudo bpftrace -e 'kprobe:udp_sendmsg {
    $sk = (struct sock *)arg0;
    $dport = ($sk->__sk_common.skc_dport >> 8) | (($sk->__sk_common.skc_dport & 0xff) << 8);
    if ($dport == 53) { @dns[comm] = count(); }
  }'
```

### TCP Retransmits

```bash
# Trace TCP retransmits with source/destination
sudo bpftrace -e 'kprobe:tcp_retransmit_skb {
    $sk = (struct sock *)arg0;
    $daddr = ntop($sk->__sk_common.skc_daddr);
    $saddr = ntop($sk->__sk_common.skc_rcv_saddr);
    $dport = ($sk->__sk_common.skc_dport >> 8) | (($sk->__sk_common.skc_dport & 0xff) << 8);
    $sport = $sk->__sk_common.skc_num;
    printf("%-20s %-6d -> %-20s %-6d (%s)\n", $saddr, $sport, $daddr, $dport, comm);
  }'
```

### Disk I/O Latency

```bash
# Block I/O latency histogram by device
sudo bpftrace -e 'tracepoint:block:block_rq_issue { @start[args->dev, args->sector] = nsecs; }
  tracepoint:block:block_rq_complete /@start[args->dev, args->sector]/ {
    @usecs[args->dev] = hist((nsecs - @start[args->dev, args->sector]) / 1000);
    delete(@start[args->dev, args->sector]);
  }'

# Top processes by disk I/O bytes
sudo bpftrace -e 'tracepoint:block:block_rq_issue {
    @bytes[comm] = sum(args->bytes);
  } interval:s:5 { print(@bytes, 10); clear(@bytes); }'
```

### Container-Aware Tracing

```bash
# Trace process exec inside containers (cgroup-filtered)
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_execve {
    printf("%-8d %-8d %-16s %s\n", pid, cgroup, comm, str(args->filename));
  }'

# Memory allocation hotspots per container
sudo bpftrace -e 'kprobe:__alloc_pages { @pages[cgroup] = count(); }
  interval:s:10 { print(@pages, 10); clear(@pages); }'
```

---

## 6. Prometheus Integration

### Hubble Metrics for Prometheus

Hubble automatically exposes Prometheus metrics when configured in the Cilium Helm install. Verify the metrics endpoint:

```bash
# Check that Hubble metrics are being served
kubectl exec -n kube-system ds/cilium -- curl -s http://localhost:9965/metrics | head -50
```

Create a ServiceMonitor for Prometheus Operator:

```yaml
# hubble-servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: hubble-metrics
  namespace: kube-system
  labels:
    app: cilium
spec:
  selector:
    matchLabels:
      k8s-app: cilium
  endpoints:
    - port: hubble-metrics
      interval: 15s
      path: /metrics
```

### eBPF Exporter for Custom Kernel Metrics

```bash
# Deploy cloudflare/ebpf_exporter for custom kernel metrics
helm repo add ebpf-exporter https://cloudflare.github.io/ebpf_exporter
helm install ebpf-exporter ebpf-exporter/ebpf-exporter \
  --namespace monitoring \
  --set config.programs[0].name=oom_kills \
  --set config.programs[0].metrics.counters[0].name=oom_kill_total \
  --set config.programs[0].metrics.counters[0].help="Total number of OOM kills"
```

Example ebpf_exporter config for tracking OOM kills and run queue latency:

```yaml
# ebpf-exporter-config.yaml
programs:
  - name: oom_kills
    metrics:
      counters:
        - name: oom_kill_total
          help: "Total number of OOM kills"
          labels:
            - name: cgroup
              size: 128
              decoders:
                - name: string
    kprobes:
      oom_kill_process: count_oom
  - name: runqlat
    metrics:
      histograms:
        - name: run_queue_latency_seconds
          help: "Run queue latency histogram in seconds"
          bucket_type: exp2
          bucket_min: 0
          bucket_max: 26
          bucket_multiplier: 0.000000001
    tracepoints:
      sched:sched_wakeup: trace_wakeup
      sched:sched_switch: trace_switch
```

### Grafana Dashboard

Import these community dashboards for eBPF metrics:

```bash
# Hubble dashboard -- Grafana dashboard ID 16611
# Cilium Agent dashboard -- Grafana dashboard ID 16612
# Cilium Operator dashboard -- Grafana dashboard ID 16613

# Or create a ConfigMap for automatic provisioning
kubectl create configmap grafana-cilium-dashboard \
  --from-file=cilium-dashboard.json \
  --namespace monitoring \
  -o yaml --dry-run=client | \
  kubectl label --local -f - grafana_dashboard=1 -o yaml | \
  kubectl apply -f -
```

Key Prometheus queries for eBPF-sourced metrics:

```promql
# Dropped packets rate by reason
rate(hubble_drop_total[5m])

# DNS error rate by query type
sum(rate(hubble_dns_responses_total{rcode!="No Error"}[5m])) by (rcode, qtypes)

# HTTP request latency (p99) from Hubble L7 visibility
histogram_quantile(0.99, sum(rate(hubble_http_request_duration_seconds_bucket[5m])) by (le, destination))

# TCP retransmit rate from eBPF exporter
rate(tcp_retransmits_total[5m])

# Run queue latency p99
histogram_quantile(0.99, sum(rate(run_queue_latency_seconds_bucket[5m])) by (le))
```

---

## 7. Network Observability

### L3/L4 Flow Logging

```bash
# Log all TCP connections with Hubble
hubble observe --type l3/l4 --protocol TCP --follow

# Filter SYN packets only (new connections)
hubble observe --type trace:to-endpoint --tcp-flags SYN --follow

# Export flows to a file for batch analysis
hubble observe --output json --since 1h > network-flows.json

# Count flows by destination service over the last hour
hubble observe --output json --since 1h | \
  jq -r '.destination.labels[] | select(startswith("k8s:app="))' | \
  sort | uniq -c | sort -rn | head -20
```

### L7 Protocol Visibility

Enable L7 visibility with Cilium annotations on target pods:

```yaml
# Annotate a namespace for HTTP visibility
apiVersion: v1
kind: Namespace
metadata:
  name: production
  annotations:
    policy.cilium.io/proxy-visibility: "<Egress/53/UDP/DNS>,<Ingress/80/TCP/HTTP>,<Ingress/443/TCP/HTTP>"
```

```bash
# Observe L7 HTTP flows
hubble observe --type l7 --protocol HTTP --follow

# Filter by HTTP status code (5xx errors)
hubble observe --type l7 --http-status "500+" --follow

# Filter by HTTP method and path
hubble observe --type l7 --http-method GET --http-path "/api/v1/.*" --follow
```

### DNS Monitoring

```bash
# All DNS queries and responses
hubble observe --type l7 --protocol DNS --follow

# DNS queries that returned NXDOMAIN
hubble observe --type l7 --protocol DNS --dns-rcode NXDOMAIN --follow

# DNS latency analysis with bpftrace
sudo bpftrace -e 'kprobe:dns_resolve { @start[tid] = nsecs; }
  kretprobe:dns_resolve /@start[tid]/ {
    @dns_latency_us = hist((nsecs - @start[tid]) / 1000);
    delete(@start[tid]);
  }'
```

### Service Dependency Map Generation

Hubble UI automatically generates service maps. For programmatic access:

```bash
# Get a service map via Hubble Relay API
hubble observe --output json --since 24h | \
  jq '{src: .source.labels, dst: .destination.labels, verdict: .verdict}' | \
  jq -s 'group_by(.src, .dst) | map({
    source: .[0].src,
    destination: .[0].dst,
    flow_count: length,
    verdicts: [.[].verdict] | group_by(.) | map({(.[0]): length}) | add
  })' > service-map.json
```

---

## 8. Security Monitoring

### Detect Container Escapes

```yaml
# container-escape-detection.yaml
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: detect-container-escape
spec:
  kprobes:
    - call: "__x64_sys_unshare"
      syscall: true
      args:
        - index: 0
          type: "int"
      selectors:
        - matchActions:
            - action: Post
    - call: "__x64_sys_mount"
      syscall: true
      args:
        - index: 0
          type: "string"
        - index: 1
          type: "string"
        - index: 2
          type: "string"
      selectors:
        - matchArgs:
            - index: 2
              operator: "Equal"
              values:
                - "proc"
                - "sysfs"
                - "cgroup"
          matchActions:
            - action: Post
    - call: "__x64_sys_ptrace"
      syscall: true
      args:
        - index: 0
          type: "int"
      selectors:
        - matchActions:
            - action: Post
```

```bash
kubectl apply -f container-escape-detection.yaml
```

### Unexpected Syscall Detection

```yaml
# unexpected-syscalls.yaml -- alert on dangerous syscalls
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: unexpected-syscalls
spec:
  kprobes:
    - call: "__x64_sys_bpf"
      syscall: true
      args:
        - index: 0
          type: "int"
      selectors:
        - matchNamespaces:
            - namespace: Pid
              operator: NotIn
              values:
                - "host_ns"
          matchActions:
            - action: Post
    - call: "__x64_sys_perf_event_open"
      syscall: true
      selectors:
        - matchNamespaces:
            - namespace: Pid
              operator: NotIn
              values:
                - "host_ns"
          matchActions:
            - action: Post
    - call: "__x64_sys_init_module"
      syscall: true
      selectors:
        - matchActions:
            - action: Sigkill
```

### File Integrity Monitoring

```yaml
# file-integrity-monitor.yaml
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: file-integrity-monitor
spec:
  kprobes:
    - call: "security_file_open"
      syscall: false
      args:
        - index: 0
          type: "file"
      selectors:
        - matchArgs:
            - index: 0
              operator: "Prefix"
              values:
                - "/etc/"
                - "/usr/bin/"
                - "/usr/sbin/"
                - "/usr/lib/"
          matchActions:
            - action: Post
              rateLimit: "1m"
    - call: "security_inode_rename"
      syscall: false
      args:
        - index: 0
          type: "path"
        - index: 1
          type: "path"
      selectors:
        - matchActions:
            - action: Post
```

```bash
kubectl apply -f file-integrity-monitor.yaml

# Stream events to your SIEM
kubectl logs -n kube-system ds/tetragon -c export-stdout -f | \
  jq 'select(.process_kprobe.policy_name == "file-integrity-monitor")' | \
  tee /dev/stderr | \
  curl -X POST -H "Content-Type: application/json" -d @- https://siem.internal/api/events
```

---

## 9. Performance Profiling

### Continuous Profiling with Parca

Parca uses eBPF to collect CPU profiles continuously with minimal overhead.

```bash
# Install Parca Agent via Helm
helm repo add parca https://parca-dev.github.io/helm-charts
helm repo update

helm install parca-agent parca/parca-agent \
  --namespace parca \
  --create-namespace \
  --set config.node=true \
  --set config.store.address="parca-server.parca.svc:7070" \
  --set config.store.insecure=true \
  --set config.debuginfo.strip=true \
  --set config.debuginfo.upload.enabled=true
```

### Continuous Profiling with Pyroscope

```bash
# Install Grafana Pyroscope with eBPF profiling
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install pyroscope grafana/pyroscope \
  --namespace pyroscope \
  --create-namespace \
  --set ebpf.enabled=true \
  --set agent.mode=ebpf
```

### CPU Flame Graphs with bpftrace

```bash
# Sample kernel and user stacks at 99Hz for 30 seconds
sudo bpftrace -e 'profile:hz:99 { @[kstack, ustack, comm] = count(); }' \
  -d 30 > stacks.out

# Using perf with BPF for flame graphs
sudo perf record -F 99 -a -g -- sleep 30
sudo perf script > perf.stacks

# Convert to flame graph (using Brendan Gregg's tools)
git clone https://github.com/brendangregg/FlameGraph.git
./FlameGraph/stackcollapse-perf.pl perf.stacks | \
  ./FlameGraph/flamegraph.pl > flamegraph.svg
```

### Off-CPU Analysis

```bash
# Trace off-CPU time to find where threads are blocked
sudo bpftrace -e '
  kprobe:finish_task_switch {
    $prev = (struct task_struct *)arg0;
    if ($prev->__state != 0) {
      @block_start[$prev->pid] = nsecs;
    }
    if (@block_start[tid]) {
      @off_cpu_us[kstack, comm] = sum((nsecs - @block_start[tid]) / 1000);
      delete(@block_start[tid]);
    }
  }
  END { print(@off_cpu_us, 20); }'
```

### Memory Leak Detection

```bash
# Track memory allocations not freed
sudo bpftrace -e '
  kprobe:kmalloc { @allocs[kstack] = count(); @bytes[kstack] = sum(arg0); }
  kprobe:kfree { @frees = count(); }
  interval:s:10 { print(@bytes, 10); }
'

# Per-process heap growth tracking
sudo bpftrace -e '
  uprobe:/lib/x86_64-linux-gnu/libc.so.6:malloc { @size[comm, tid] = sum(arg0); }
  interval:s:5 { print(@size, 10); clear(@size); }
'
```

---

## 10. Troubleshooting

### Common eBPF Issues

**BPF verifier rejects program:**

```bash
# Get verbose verifier output
sudo bpftrace -d -e 'your_program_here' 2>&1 | tail -50

# Common causes:
# - Unbounded loops (BPF requires bounded loops or unrolled iterations)
# - Stack size exceeds 512 bytes
# - Accessing memory without null checks
# - Back-edges in control flow (pre-5.3 kernels)
```

**BTF not available:**

```bash
# Check if BTF is compiled into the kernel
cat /boot/config-$(uname -r) | grep CONFIG_DEBUG_INFO_BTF

# If not, install BTF data from btfhub
# https://github.com/aquasecurity/btfhub
wget "https://github.com/aquasecurity/btfhub-archive/raw/main/ubuntu/22.04/x86_64/$(uname -r).btf.tar.xz"
tar xvf "$(uname -r).btf.tar.xz"
```

**Permission denied:**

```bash
# BPF requires CAP_BPF (or CAP_SYS_ADMIN on older kernels)
# For containers, add to securityContext:
# securityContext:
#   capabilities:
#     add: ["BPF", "PERFMON", "SYS_RESOURCE"]

# Check current capabilities
cat /proc/self/status | grep Cap
capsh --decode=$(cat /proc/self/status | grep CapEff | awk '{print $2}')
```

**Cilium pods not starting:**

```bash
# Check Cilium agent logs
kubectl logs -n kube-system -l k8s-app=cilium --tail=100

# Verify BPF filesystem
kubectl exec -n kube-system ds/cilium -- mount | grep bpf

# Check for conflicting CNIs
ls /etc/cni/net.d/

# Run Cilium connectivity test
cilium connectivity test
```

**Tetragon events missing:**

```bash
# Verify TracingPolicy is loaded
kubectl get tracingpolicies

# Check Tetragon agent logs for verifier errors
kubectl logs -n kube-system ds/tetragon -c tetragon --tail=200 | grep -i error

# Verify the kprobe is attached
kubectl exec -n kube-system ds/tetragon -c tetragon -- \
  cat /sys/kernel/debug/kprobes/list | grep your_function
```

**High overhead from eBPF programs:**

```bash
# List all loaded BPF programs and their run time
sudo bpftool prog show
sudo bpftool prog profile id <PROG_ID> duration 5

# Check map memory usage
sudo bpftool map show
sudo bpftool map dump id <MAP_ID> | wc -l

# If a program is consuming too much CPU, check its run count and time
sudo bpftool prog show id <PROG_ID> --json | jq '{run_cnt, run_time_ns}'

# Detach a misbehaving program
sudo bpftool prog detach id <PROG_ID> type <ATTACH_TYPE>
```

### Kernel Compatibility Matrix

```bash
# Quick check: which eBPF features your kernel supports
sudo bpftool feature probe kernel

# Check specific program types
sudo bpftool feature probe kernel | grep program_type

# Check available map types
sudo bpftool feature probe kernel | grep map_type

# Check available helper functions
sudo bpftool feature probe kernel | grep helper
```
