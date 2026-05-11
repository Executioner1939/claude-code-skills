---
name: k8s-runtime-contract
internal: true
---

# Kubernetes runtime contract

**Audience:** internal — loaded only by the `deployment-verifier` subagent.

This skill encodes the contract between a workload and the kubelet: the three
probes, the termination sequence, resource accounting, and the application
behaviors that make those mechanisms work. Every claim cites its upstream
source so the verifier can quote it back at the user.

---

## 1. Probes: readiness, liveness, startup

Source: [Kubernetes — Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) and [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).

### Semantic differences (this is the most-confused topic in the checklist)

| Probe | When it runs | What failure does | Why it exists |
|---|---|---|---|
| **startupProbe** | First. Gates the other two. | kubelet **kills** the container and restarts it per `restartPolicy`. | Slow-starting apps (JVM warmup, cache prime, schema migration on boot) should not be killed by an aggressive liveness probe during the boot window. |
| **livenessProbe** | After startup succeeds, for the container's lifetime. | kubelet **kills** the container and restarts it. | Detect unrecoverable runtime hangs (deadlocks, stuck event loop) where the only fix is a restart. |
| **readinessProbe** | After startup succeeds, for the container's lifetime. | Pod is **removed from Service endpoints**. The container keeps running. | Temporary unavailability — warming caches, draining DB connections, waiting on a dependency. Routes traffic away without churning the pod. |

### Decision rules the verifier applies

1. **All three probes must reach distinct decisions.** A common anti-pattern is
   using the same `/health` endpoint for liveness and readiness — if the
   dependency check fails, kubelet restarts the pod (liveness) instead of just
   removing it from endpoints (readiness). Restarting does not fix a downstream
   outage; it just turns one bad pod into a CrashLoopBackOff fleet.
2. **Liveness should answer "is *this process* dead?"** — not "is the whole
   stack healthy?". A typical liveness check is a cheap in-process counter or
   a TCP socket open. Anything touching the network, the database, or another
   pod belongs in readiness.
3. **Readiness should answer "should I get traffic *right now*?"** — it must
   return false during graceful shutdown (see §2), during cache warm-up, and
   when a critical downstream is failing.
4. **Startup is required when first-byte latency > `failureThreshold *
   periodSeconds` of the liveness probe.** Otherwise the app gets killed mid-boot.

### Probe field defaults (kubelet)

Source: [Probe API v1 reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.32/#probe-v1-core).

| Field | Default | What it means |
|---|---|---|
| `initialDelaySeconds` | `0` | Wait before the first probe. Prefer **startupProbe** over a large `initialDelaySeconds` — it adapts to actual boot time. |
| `periodSeconds` | `10` | How often the probe runs. |
| `timeoutSeconds` | `1` | The probe call itself must return in this time. Too low causes flapping under load. |
| `failureThreshold` | `3` | Consecutive failures before action. For liveness, this is the only thing standing between a hiccup and a restart. |
| `successThreshold` | `1` | For readiness: 1 success returns the pod to endpoints. Liveness/startup must be 1. |

### Worked example — Java service with 45s warmup

```yaml
# Source pattern: https://kubernetes.io/docs/tasks/configure-pod-container/
#   configure-liveness-readiness-startup-probes/#protect-slow-starting-containers
startupProbe:
  httpGet: { path: /healthz/started, port: http }
  failureThreshold: 30        # 30 * 10s = 5 minutes max boot budget
  periodSeconds: 10
livenessProbe:
  httpGet: { path: /healthz/live, port: http }
  periodSeconds: 10
  failureThreshold: 3         # 30s of consecutive failure -> restart
  timeoutSeconds: 2
readinessProbe:
  httpGet: { path: /healthz/ready, port: http }
  periodSeconds: 5
  failureThreshold: 2         # remove from endpoints fast
  successThreshold: 1
  timeoutSeconds: 2
```

The three endpoints **must be different code paths** in the app:

- `/healthz/started` — flips true once after the boot sequence finishes (once).
- `/healthz/live` — returns 200 unless an in-process invariant has broken
  (e.g., the goroutine that drains the work queue has died). It does **not**
  call out to dependencies.
- `/healthz/ready` — returns 200 only when *all* of: started, not draining,
  and required downstreams are reachable.

### What the verifier flags

- Same probe handler used for two or more probes → **FAIL** with citation to
  the upstream guidance.
- `livenessProbe` calling a dependency (DB, Redis, another service) → **FAIL**
  — a downstream outage will cascade into pod restarts.
- `readinessProbe` missing → **FAIL** — traffic will hit the pod the instant
  it has an IP, before the app is ready.
- App startup time exceeds the liveness `failureThreshold * periodSeconds` and
  no `startupProbe` is set → **FAIL** — boot loop on first deploy.
- `initialDelaySeconds` > 60 with no `startupProbe` → **WARN** — replace with
  a startup probe that adapts.

---

## 2. Graceful shutdown: SIGTERM, `preStop`, `terminationGracePeriodSeconds`

Source: [Kubernetes — Pod termination](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination).

### The exact sequence (this is the one most apps get wrong)

1. The pod is marked `Terminating`. The Pod is **removed from Service
   endpoints immediately** by the EndpointSlice controller, but kube-proxy on
   every node must propagate that change — which takes a non-zero amount of
   time. Until propagation finishes, **new requests will keep arriving**.
2. The container's `preStop` hook (if defined) runs to completion.
3. The kubelet sends **SIGTERM** to the container's main process.
4. The kubelet starts the `terminationGracePeriodSeconds` countdown (default
   30s). This countdown **includes** the time the `preStop` hook took.
5. When the grace period expires, the kubelet sends **SIGKILL**. There is no
   negotiation.

### The two failure modes

- **App ignores SIGTERM** (e.g., a Node.js HTTP server with no signal handler,
  or a JVM app whose framework does not wire shutdown hooks). The app runs
  until SIGKILL hits at the grace deadline. Any in-flight request is severed
  mid-write — clients see TCP RST.
- **App stops accepting new connections immediately on SIGTERM but kube-proxy
  hasn't propagated the endpoint removal yet.** New connections land on a pod
  that won't serve them. Clients see connection-refused.

### The fix

```yaml
# Pattern from: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/
lifecycle:
  preStop:
    exec:
      # Sleep long enough for kube-proxy / Ingress / SM controllers to
      # propagate endpoint removal. The app's readiness probe should ALSO
      # flip to NotReady at this point if implemented in-process.
      command: ["/bin/sh", "-c", "sleep 15"]
terminationGracePeriodSeconds: 60   # > preStop(15s) + longest in-flight request
```

Application code must:

- Install a SIGTERM handler.
- Flip the readiness signal to `false` immediately.
- Stop accepting new connections.
- Wait for in-flight requests to complete (with a hard deadline < grace
  period).
- Close upstream connections (DB pools, message brokers) cleanly.

### What the verifier flags

- `terminationGracePeriodSeconds` not set or set < default 30s for any
  workload handling HTTP traffic → **WARN**.
- `preStop` absent on a Deployment exposed via Service → **WARN** with the
  kube-proxy propagation rationale.
- App code without a SIGTERM handler (grep for `SIGTERM`, `signal.Notify`,
  `process.on('SIGTERM')`, `Runtime.getRuntime().addShutdownHook`,
  `signal.signal(SIGTERM, …)`) → **FAIL**.

---

## 3. Resource requests and limits

Source: [Kubernetes — Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).

### The rules behind the rule

- **Requests** drive scheduling. Sum of requests across containers in a pod
  determines which node it lands on. They also set the QoS class.
- **Limits** drive enforcement. CPU limits throttle the container via
  `cgroups.cpu.cfs_quota_us`; memory limits trigger the OOM killer.
- **QoS classes**:
  - `Guaranteed` — every container has requests == limits for both CPU and
    memory. Last to be evicted.
  - `Burstable` — at least one container has a request but request != limit
    somewhere. Evicted under node pressure ordered by how far above its
    request it is using.
  - `BestEffort` — no requests or limits anywhere. First to be evicted.

### CPU limits are a near-universal anti-pattern

CPU is compressible — the kernel will just give a busy container less of it
when the node is contended. **CPU limits** add throttling on top of that,
which produces tail latency spikes that look like a bug in the app but are
actually CFS throttling. Recommendation in the Kubernetes community
(e.g. [Tim Hockin's
note](https://github.com/kubernetes/kubernetes/issues/67577)) is: set CPU
**requests** based on real usage, omit CPU **limits** unless you have a hard
multi-tenancy reason. Memory limits, by contrast, are mandatory — memory is
not compressible.

### Sizing methodology

1. Run the workload under representative load (k6 / Locust / Vegeta).
2. Capture `container_cpu_usage_seconds_total` and
   `container_memory_working_set_bytes` from kubelet/cAdvisor over a
   long-enough window to include all relevant duty cycles (cron jobs, GC
   cycles, traffic peaks).
3. Set CPU request = p99 of observed CPU over 5-minute windows.
4. Set memory request = p99 working-set. Set memory limit = memory request
   * 1.2 — 1.5 (room for legitimate spikes; OOM at 1.5x is a real bug, not
   a noisy-neighbor symptom).
5. Re-evaluate quarterly with VPA in `recommendation-only` mode (see
   [`k8s-scaling-resilience`](../k8s-scaling-resilience/SKILL.md)).

### What the verifier flags

- Any container with no `resources.requests` → **FAIL** (BestEffort = first to
  be evicted, breaks the bin-pack).
- Memory request without memory limit → **WARN** (an unbounded leak takes
  out the node).
- CPU limit present and no documented multi-tenancy reason → **WARN** with
  the throttling explanation.
- `resources.requests.cpu` divisible by 1000m with no fractional component
  (e.g. `1`, `2`) and no load-test data referenced → **WARN** ("looks like
  a guess").

---

## 4. Ephemeral storage

Source: [Kubernetes — Local ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#local-ephemeral-storage).

Pods writing logs to disk, materializing files in `emptyDir`, or relying on
`/tmp` consume the node's ephemeral storage. When a node runs out, kubelet
evicts pods — silently — ordered by ephemeral-storage usage above their
request.

The verifier requires:

- `resources.requests.ephemeral-storage` set on any container that writes
  to disk (detected via `emptyDir` volumes, log paths, file uploads in code).
- `resources.limits.ephemeral-storage` set with the same upper-bound logic
  as memory.

---

## 5. The application-side contract

The Kubernetes mechanics above only work if the application cooperates.
Source: the [Twelve-Factor App](https://12factor.net/) plus the LearnKube
checklist.

| Behavior | Why kubelet/kube-proxy depends on it |
|---|---|
| **Logs to `stdout`/`stderr`** | Container runtime captures these; kubectl logs, Loki, Fluent Bit DaemonSet all read from here. Logging to a file under `/var/log` requires a sidecar to ship it, which is more parts that can break. |
| **Config from env or mounted files** | Pods are immutable. The only way config changes is rolling the pods. Reading a host file or a remote config service breaks the rolling-update contract. |
| **Handles SIGTERM gracefully** | See §2. |
| **Exposes health signals** | See §1. |
| **No local-disk state** | Pod rescheduling onto a new node loses local disk. Use a `PersistentVolumeClaim` if state is real; use external storage (S3, GCS) otherwise. |
| **Handles long-lived connections** | gRPC, WebSocket, SSE clients pin to a pod IP via L4. When the pod terminates, clients must reconnect; the app needs to send `GOAWAY` (gRPC) or close the WebSocket with a code that triggers retry. |

The verifier scans the language-appropriate signals:

- **Go:** `signal.NotifyContext`, `http.Server.Shutdown`, `os.Stdout` writes.
- **Node:** `process.on('SIGTERM', …)`, `server.close(…)`, no `winston` file
  transports.
- **Java:** `Runtime.getRuntime().addShutdownHook`, Spring Boot graceful
  shutdown (`server.shutdown=graceful`), `log4j2.xml` `ConsoleAppender`.
- **Python:** `signal.signal(SIGTERM, …)`, uvicorn `--graceful-timeout`,
  `logging.StreamHandler(sys.stdout)`.
- **Rust:** `tokio::signal::unix::signal(SIGTERM)`, axum/tonic graceful
  shutdown future.
