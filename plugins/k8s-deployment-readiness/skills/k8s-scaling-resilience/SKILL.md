---
name: k8s-scaling-resilience
internal: true
---

# Kubernetes scaling & resilience

**Audience:** internal — loaded only by the `deployment-verifier` subagent.

The LearnKube "Scaling" section in depth: horizontal vs vertical, autoscaler
tuning, priority classes, load-test validation.

---

## 1. Horizontal Pod Autoscaler

Source: [Kubernetes — Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and [`autoscaling/v2`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.32/#horizontalpodautoscaler-v2-autoscaling).

### Scaling model preconditions

HPA only works on workloads that are *actually* horizontally scalable. The
verifier rejects horizontal autoscaling on workloads with these red flags:

- **Sticky sessions terminated at the application.** If session affinity
  lives in process memory, scaling out splits sessions across pods that
  can't see each other.
- **Singleton background workers.** A leader-elected component (cron jobs,
  schedulers, single-writer caches) must not scale on a metric — it scales
  to N=1 by definition. Use a `Deployment` with `replicas: 1` and a
  PodDisruptionBudget, not HPA.
- **Workloads that touch a fixed-cardinality external resource.** Scaling
  10 pods of a workload that opens 100 connections each against a database
  with a 200-connection limit creates a connection-pool incident, not a
  performance win.

### The standard shape

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: { name: api }
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api
  minReplicas: 3            # never below 3 in prod — see §2
  maxReplicas: 30           # explicit ceiling
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300   # don't scale down for 5 minutes after a peak
      policies:
        - type: Percent
          value: 10                    # remove at most 10% of pods per minute
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0    # scale up immediately
      policies:
        - type: Percent
          value: 100
          periodSeconds: 30
        - type: Pods
          value: 4
          periodSeconds: 30
      selectPolicy: Max
```

### Why both `behavior` policies are required

- Default `scaleDown.stabilizationWindowSeconds` is **300s**, which is fine,
  but defaults to **removing 100% of pods per minute** — meaning a single
  metric dip can collapse the fleet. Always cap with a `Percent` policy.
- Default `scaleUp` is fast enough, but specifying `selectPolicy: Max` and
  both Percent + Pods policies handles the cold-start case (when you have
  3 pods and need to double in 30s, `Percent: 100` gives you 6 — but
  `Pods: 4` gives you 7, and `Max` picks the bigger).

### CPU is rarely the right signal

CPU utilization scales fine for compute-bound services. For most production
services the *actual* bottleneck is concurrent in-flight requests, queue
depth, or downstream latency. Use **custom metrics** via `external` /
`object` / `pods` HPA metric sources, fed by a metrics adapter
(prometheus-adapter, KEDA).

```yaml
metrics:
  - type: Pods
    pods:
      metric: { name: http_inflight_requests }
      target:
        type: AverageValue
        averageValue: "30"          # 30 in-flight requests per pod
```

KEDA opens up dozens of event-driven scalers: Kafka lag, SQS depth, RabbitMQ
queue length, NATS pending, cron, Prometheus query, Datadog query.

### What the verifier flags

- `maxReplicas` unset or `> 100x minReplicas` → **WARN** (a runaway loop
  becomes a budget incident).
- `minReplicas: 1` on a tier-1 workload → **FAIL** — a zone outage takes the
  whole service offline.
- `scaleDown.stabilizationWindowSeconds` < 60 → **WARN**.
- HPA on a singleton/stateful workload → **FAIL**.

---

## 2. Vertical Pod Autoscaler

Source: [VPA repository](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler).

VPA is **not** a substitute for HPA — it adjusts a pod's requests/limits,
which requires recreating the pod. The recommended posture:

- VPA in `Off` (recommendation-only) mode in every prod namespace.
  Operators read the recommendations and update Helm values during normal
  release cycles.
- VPA in `Auto` mode only for batch workloads where pod recreation is free.
- **Never** run VPA in `Auto` mode together with HPA on CPU/memory —
  they fight: HPA scales out because pods are loaded, VPA grows the pods,
  HPA scales in, repeat.

VPA `Auto` mode + HPA on a custom metric (queue depth) is fine — they target
different axes.

---

## 3. Resource requests informed by real usage

This is the entry point that connects sizing to load testing. The verifier
asks: **what data justifies these request values?**

Acceptable evidence:

- A linked load-test artifact (k6 / Locust / Vegeta script in the repo,
  pointed at staging).
- A Grafana dashboard URL showing actual CPU/memory percentiles for the
  workload over a meaningful window (24h minimum, 7d preferred).
- A VPA recommendation snapshot in the commit message or PR body.

Unacceptable evidence:

- "We always use 250m / 256Mi" — culturally pervasive, technically wrong.
- The number copied from another service.
- The default from the Helm chart with no overlay.

### What the verifier flags

- No load-test script or VPA recommendation referenced in the PR / repo
  → **WARN** (the "scaling has been load-tested" item).
- Requests identical across all containers in a multi-tenant Helm release
  → **WARN** (suspiciously uniform).

---

## 4. Priority classes

Source: [Kubernetes — Pod Priority and Preemption](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/).

When the cluster is full, the scheduler decides who to preempt. Without
priority classes that decision is essentially random. With them:

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata: { name: tier-1-critical }
value: 1000000
globalDefault: false
description: "User-facing, revenue-impacting workloads."
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata: { name: tier-2-important }
value: 100000
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata: { name: tier-3-batch }
value: 1000
preemptionPolicy: Never        # don't preempt anyone — just sit in pending
```

Values are arbitrary; spread them widely so future tiers fit between
existing ones. `system-cluster-critical` (2000000000) and `system-node-critical`
(2000001000) are reserved by Kubernetes for control-plane pods — don't
exceed them.

### What the verifier flags

- Production-tier workload without `priorityClassName` → **WARN** — its
  priority is `0` and any system pod can preempt it.
- Two workloads at different criticality levels but the same
  `priorityClassName` → **WARN**.

---

## 5. Cluster Autoscaler / Karpenter

Source: [Cluster Autoscaler FAQ](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md) and [Karpenter docs](https://karpenter.sh/docs/).

The HPA scales pods; you also need something to scale nodes. The verifier
checks the IaC for one of:

- **Cluster Autoscaler** with explicit `--scale-down-utilization-threshold`,
  `--scale-down-unneeded-time`, and a sane `--max-nodes-total`.
- **Karpenter** (AWS, increasingly other clouds) with `NodePool` /
  `EC2NodeClass` resources defining instance families, capacity types
  (spot vs on-demand), consolidation policy, and disruption budgets.

PDBs from
[`k8s-rollout-strategy`](../k8s-rollout-strategy/SKILL.md) gate
Karpenter's consolidation just like they gate `kubectl drain`. Workloads
without a PDB get evicted whenever Karpenter rebalances — which can be
surprisingly often.

### What the verifier flags

- Cluster autoscaling configured but no PDBs on the tenant workloads →
  **WARN** (every consolidation is a mini-incident).
- Karpenter `NodePool` allowing `spot` with no `consolidation` budget and
  no `taints` to opt-in workloads → **WARN**.

---

## 6. Scale-down drains traffic cleanly

This is where graceful shutdown (see
[`k8s-runtime-contract`](../k8s-runtime-contract/SKILL.md) §2) intersects
with scale-down. When HPA removes a pod:

1. HPA decreases the Deployment's `replicas`.
2. The Deployment controller picks a victim pod and deletes it.
3. The kubelet runs the termination flow (preStop → SIGTERM → grace period
   → SIGKILL).

The same `preStop` sleep + readiness gate that keeps rolling updates
clean keeps scale-down clean. The verifier confirms both are present.

---

## 7. Load testing the scaling path

The checklist item is not "have you load-tested the application" but
"have you load-tested the **scaling path**" — i.e., the moment when
HPA fires. Useful evidence:

- A k6 scenario that ramps load over the HPA's `stabilizationWindowSeconds`
  and confirms latency stays bounded.
- A chaos experiment (Litmus, Chaos Mesh) that kills the busiest pod and
  watches for capacity recovery within the SLO.
- A game-day record of a zone-failure simulation — does HPA scale up in
  the surviving zones fast enough?
