# k8s-deployment-readiness

Three-gate Kubernetes deployment readiness workflow derived from
[learnkube.com/production-best-practices](https://learnkube.com/production-best-practices).

Each gate is a slash command that orchestrates two read-only subagents against
**application code**, **Kubernetes manifests** (Helm, Kustomize, raw YAML),
**Terraform** modules, and **GitOps** repositories (Argo CD / Flux):

| Command | Purpose | When to run |
|---|---|---|
| `/k8s-deployment-readiness:develop` | Catch contract violations in the inner loop — app behavior, image, basic probes, instrumentation hooks, secret hygiene. | While the feature branch is open. |
| `/k8s-deployment-readiness:staging` | UAT/staging gate — real probe verification, resource sizing from load data, NetworkPolicy, PSS, HPA bounds, OTel pipeline end-to-end. | Before promoting a release candidate to UAT. |
| `/k8s-deployment-readiness:production` | Go-live gate — PDBs, multi-zone spread, admission policies, runbooks, multi-burn-rate SLO alerts, DR, cost. | Before the production cutover. |

## How it works

Each command dispatches **two subagents**:

- **`deployment-verifier`** — checks app code + manifests + Helm/Kustomize +
  Terraform + GitOps configs against the gate's checklist. Loads four internal
  skills: `k8s-runtime-contract`, `k8s-rollout-strategy`,
  `k8s-supply-chain-security`, `k8s-scaling-resilience`, plus
  `k8s-iac-compliance` when Terraform or GitOps repos are in scope.

- **`observability-auditor`** — audits metrics, traces, logs, and SLO/alerting
  posture against the OpenTelemetry semantic conventions and the Google SRE
  multi-burn-rate alerting playbook. Loads `k8s-observability-metrics` and
  `k8s-iac-compliance`.

The six skills are **internal**: they have no `description` that would make
them auto-loadable for the user. They are only attached to the two subagents
via their `skills:` frontmatter, keeping the user-facing surface minimal.

## What it scans

The verifier auto-detects what to check:

- **Application code** — language idioms for `stdout` logging, `SIGTERM`
  handling, env-driven config, graceful connection drain, statelessness.
- **Manifests** — `Deployment`, `StatefulSet`, `Service`, `Ingress`,
  `HorizontalPodAutoscaler`, `PodDisruptionBudget`, `NetworkPolicy`,
  `ServiceAccount`, `Role`/`RoleBinding`, `Namespace` labels (PSS).
- **Helm / Kustomize** — `values.yaml`, `Chart.yaml`, overlays, `kustomization.yaml`.
- **Terraform / OpenTofu** — EKS/GKE/AKS module inputs, IRSA/Workload Identity,
  KMS, registry policies, networking, ALB/Ingress controller config.
- **GitOps** — Argo CD `Application` / `ApplicationSet`, Flux
  `Kustomization` / `HelmRelease`, sync waves, retry policies, sync windows,
  image automation.

Every finding cites the file:line that triggered it.

## Output

A single `index.md` per run with:

- Gate verdict: `PASS` / `PASS_WITH_WARNINGS` / `FAIL`
- Checklist-grouped findings (one row per item, file:line, fix)
- Decision queue for items the human must answer
- Observability deep-dive section with four sourced metric/SLO examples tailored to the workload
- Re-run command for fast iteration

## Sources

The checklist text is sourced directly from
[Learn Kubernetes — Production Best Practices](https://learnkube.com/production-best-practices).
Technical depth is drawn from the upstream Kubernetes documentation, the
[OpenTelemetry semantic conventions](https://opentelemetry.io/docs/specs/semconv/),
[Google SRE workbook — Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/),
the Prometheus histogram practices guide, Tom Wilkie's RED method, and
Brendan Gregg's USE method. Skill files cite the precise URL per claim.
