---
name: k8s-rollout-strategy
internal: true
---

# Kubernetes rollout strategy

**Audience:** internal — loaded only by the `deployment-verifier` subagent.

The runtime contract (see [`k8s-runtime-contract`](../k8s-runtime-contract/SKILL.md))
makes a *single* pod safe to start and stop. This skill covers what happens
when many pods of different versions exist at once, when nodes are drained,
and when zones go away.

---

## 1. Rolling update settings

Source: [Kubernetes — Deployment rolling update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment).

### Defaults and why they are wrong for production

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 25%        # default
    maxUnavailable: 25%  # default
```

The defaults allow **25% of pods to be unavailable** at any point. For a
3-replica Deployment, that rounds up to one pod missing — fine. For a
20-replica fleet during a global incident, that is 5 pods missing — possibly
intolerable. Set these explicitly per workload tier:

```yaml
# tier-1 (user-facing, latency-sensitive)
rollingUpdate:
  maxSurge: 1
  maxUnavailable: 0       # zero-disruption rollout
# tier-3 (batch worker)
rollingUpdate:
  maxSurge: 50%
  maxUnavailable: 50%     # ship fast, can tolerate gaps
```

`maxUnavailable: 0` requires `maxSurge >= 1` — there must be somewhere for
the new pod to land before an old one is removed.

### What the verifier flags

- `strategy` block missing → **WARN** (defaults apply, but it should be
  explicit per the checklist).
- `maxUnavailable: 25%` and `replicas <= 4` → **FAIL** — under-replicated
  rolling updates lose half the fleet briefly.
- `strategy.type: Recreate` on anything user-facing → **FAIL** — every
  rollout is a full outage.

---

## 2. The "old and new pods running together" contract

Source: LearnKube checklist + [Kubernetes — Versioning resources](https://kubernetes.io/docs/reference/using-api/deprecation-policy/).

During every rolling update there is a window — sometimes hours, sometimes
seconds — when version N and version N+1 are both serving traffic against
the same database, the same message bus, the same cache. The verifier checks
for the common failure modes:

| Concern | What to check |
|---|---|
| **Database migrations** | Migrations must be backward-compatible across one version (additive only: add columns nullable, never rename/drop in the same release as the code change). The two-step expand/contract pattern is the only safe one. |
| **Message schemas** | New consumers must read old messages; old consumers must ignore unknown fields (Protobuf reserved tags, Avro defaults). Reject schemas that require both sides to upgrade atomically. |
| **Cache keys** | Cache key formats must be stable, or new pods must read both shapes during the rollout. |
| **API contracts internal-to-internal** | A new field consumed by version N+1's frontend must be served by version N+1's backend before the frontend rollout begins. This is a *release ordering* constraint, not just a code constraint. |

The verifier scans recent commits and migration files (`migrations/`,
`db/migrate/`, `flyway/`, `liquibase/`, `prisma/migrations/`) and flags
non-additive operations (`DROP COLUMN`, `RENAME`, `ALTER … NOT NULL` without
a default backfill) that are landing in the same release as code changes.

---

## 3. ConfigMap and Secret reload strategy

Source: [Kubernetes — Updating ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/#mounted-configmaps-are-updated-automatically).

A ConfigMap mounted as a volume is updated **in-place** in the pod — but the
running process holds the file descriptor open and never re-reads it unless
the app explicitly watches the file. The verifier flags this gap explicitly.

The three viable patterns:

1. **Annotate-and-roll** (most teams, lowest cognitive load): the
   Deployment's `spec.template.metadata.annotations` carries a hash of the
   ConfigMap contents (Helm's `checksum/config:`). Changing the ConfigMap
   changes the hash, which changes the Pod template, which triggers a normal
   rolling update. The app never needs to know about reload.

   ```yaml
   spec:
     template:
       metadata:
         annotations:
           checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
   ```

2. **In-process file watch** — the app uses `fsnotify` (Go), `chokidar`
   (Node), `inotify` (Python `watchfiles`). Reserved for cases where rolling
   is expensive (stateful workloads, long-lived connections).

3. **Sidecar reloader** — `stakater/Reloader` watches ConfigMap/Secret
   changes and patches the owning workload to trigger a roll. Useful for
   workloads you don't own but must keep in sync.

The verifier rejects "edit the ConfigMap, hope for the best" workflows.

---

## 4. PodDisruptionBudget

Source: [Kubernetes — Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/).

### What it actually does

A PDB constrains **voluntary disruptions** — `kubectl drain`, cluster
autoscaler scale-down, node-upgrade controllers. The eviction API consults
every matching PDB; if granting the eviction would violate any PDB, the
eviction is denied.

**A PDB does not protect against involuntary disruptions** — node hardware
failure, kernel panic, zone outage. Quoting the upstream doc directly:

> "The budget can only protect against voluntary evictions, not all causes of
> unavailability."

> "A node that hosts a pod from the collection may fail when the collection
> is at the minimum size specified in the budget, thus bringing the number
> of available pods from the collection below the specified size."

### `minAvailable` vs `maxUnavailable`

Pick exactly one — the upstream doc says you cannot set both.

- `minAvailable: 2` — evictions allowed only if **at least 2** healthy pods
  remain. Good for fixed-size replicas.
- `maxUnavailable: 25%` — evictions allowed only if **no more than 25%** of
  the fleet is unhealthy. Good for fleets that scale with HPA.

### The cardinal mistake

`maxUnavailable: 0` (or `minAvailable: 100%`) makes the workload
**undrainable**. From the upstream doc:

> "you cannot successfully drain a Node running one of those Pods. If you
> try to drain a Node where an unevictable Pod is running, the drain never
> completes."

The verifier rejects this. Single-replica workloads with strict
`minAvailable: 1` are also flagged — a node drain will stall forever.

### Standard shapes by workload tier

```yaml
# tier-1, fleet of 6+
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata: { name: api }
spec:
  maxUnavailable: 1
  selector:
    matchLabels: { app: api }
```

```yaml
# stateful, leader-required (e.g., Postgres primary)
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata: { name: pg-primary }
spec:
  minAvailable: 1
  selector:
    matchLabels: { app: pg, role: primary }
```

---

## 5. Topology spread and anti-affinity

Source: [Kubernetes — Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/).

A 6-replica Deployment that happens to land all 6 pods on the same node, or
in the same zone, has the same blast radius as a 1-replica Deployment when
that unit of failure goes away.

Use `topologySpreadConstraints` (modern, preferred over
`podAntiAffinity`):

```yaml
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: ScheduleAnyway   # do not deadlock the scheduler
    labelSelector:
      matchLabels: { app: api }
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels: { app: api }
```

The verifier requires:

- Spread by `topology.kubernetes.io/zone` for any workload labeled
  `tier=1` or `tier=2`, with `maxSkew: 1`.
- `whenUnsatisfiable: ScheduleAnyway` — `DoNotSchedule` is reserved for the
  rare workload where availability is worth permanent pending pods.
- `replicas >= zones` if zone-spread is enforced strictly; otherwise the
  constraint is unsatisfiable.

---

## 6. Secrets handling

Source: [Kubernetes — Secrets best practices](https://kubernetes.io/docs/concepts/security/secrets-good-practices/).

### Volumes, not env vars

A secret passed via `env` ends up in:

- The container's process environment — visible via `/proc/<pid>/environ`
  to anything with the right namespace.
- Application crash dumps, error reporters (Sentry, Rollbar) that capture
  environ.
- `kubectl describe pod` output, which CI logs may render.

A secret mounted as a volume:

- Is delivered as a tmpfs file readable only by the pod.
- Can be rotated in-place (with the reload caveats from §3).
- Does not appear in environ dumps.

```yaml
volumes:
  - name: db-creds
    secret:
      secretName: db-creds
      defaultMode: 0400
containers:
  - name: app
    volumeMounts:
      - name: db-creds
        mountPath: /var/run/secrets/db
        readOnly: true
```

The verifier rejects `valueFrom.secretKeyRef` for anything named like a
credential (`*_PASSWORD`, `*_TOKEN`, `*_KEY`, `*_SECRET`) — those go via
mounted volumes, or via the external secret store (see
[`k8s-supply-chain-security`](../k8s-supply-chain-security/SKILL.md)).

### Labels

Resources need `app.kubernetes.io/name`, `app.kubernetes.io/instance`,
`app.kubernetes.io/version`, `app.kubernetes.io/component`,
`app.kubernetes.io/part-of`, `app.kubernetes.io/managed-by`. These are the
[recommended labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/);
everything from kubectl filters to Argo CD application grouping depends on
them.

### API version drift

The verifier compares `apiVersion` on every manifest against the cluster's
server version (or the target cluster version, if known). Resources using
deprecated APIs (`extensions/v1beta1`, `policy/v1beta1`, `autoscaling/v2beta2`,
`networking.k8s.io/v1beta1` Ingress, etc.) fail the gate with a citation
to [`kubectl convert`](https://kubernetes.io/docs/tasks/tools/included/kubectl-convert-overview/)
or the corresponding migration page.
