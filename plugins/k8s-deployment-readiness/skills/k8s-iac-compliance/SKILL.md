---
name: k8s-iac-compliance
internal: true
---

# Terraform / GitOps compliance scanning

**Audience:** internal — loaded by both subagents (`deployment-verifier`
and `observability-auditor`) when an IaC or GitOps repo is in scope.

The skill describes how to verify Kubernetes production-readiness items
against **infrastructure-as-code** (Terraform, OpenTofu) and **GitOps**
configurations (Argo CD, Flux), rather than (or in addition to) the
in-cluster state.

The scanning is read-only. The verifier never applies, never mutates, never
talks to a live cluster.

---

## 1. Detection

The verifier auto-detects what to scan by walking the repo:

| Signal | What it means |
|---|---|
| `*.tf`, `*.tofu`, `terraform.lock.hcl` | Terraform / OpenTofu module. |
| `kustomization.yaml` | Kustomize overlay or base. |
| `Chart.yaml`, `values*.yaml`, `templates/` | Helm chart or release. |
| `Application` / `ApplicationSet` (apiVersion `argoproj.io/*`) | Argo CD. |
| `Kustomization` (apiVersion `kustomize.toolkit.fluxcd.io/*`) or `HelmRelease` (apiVersion `helm.toolkit.fluxcd.io/*`) | Flux. |
| `cluster.yaml` with `eksctl.io/v1alpha5` apiVersion | eksctl. |
| `Cluster` (apiVersion `cluster.x-k8s.io/*`) | Cluster API. |

If none of these are present, the verifier reports "no IaC scope detected"
and limits findings to in-repo manifests and application code.

---

## 2. Terraform cluster-side checks

These map LearnKube checklist items to specific Terraform resource
attributes. The verifier scans HCL with regex-level fidelity (no `terraform
plan` execution).

### EKS

| Checklist item | Terraform attribute | Source |
|---|---|---|
| etcd KMS encryption | `resource "aws_eks_cluster" "*"` → `encryption_config.provider.key_arn` set, `resources = ["secrets"]` | [AWS — EKS secrets encryption](https://docs.aws.amazon.com/eks/latest/userguide/envelope-encryption.html) |
| Audit logging | `enabled_cluster_log_types` includes `"audit"`, `"authenticator"`, `"api"` | [AWS — EKS control plane logs](https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) |
| Public endpoint locked down | `vpc_config.endpoint_public_access = false` OR `endpoint_public_access_cidrs` set to a small list | [AWS — Cluster endpoint access](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html) |
| OIDC provider for IRSA | `resource "aws_iam_openid_connect_provider"` present and tied to the cluster's OIDC issuer | [AWS — IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) |
| Node-group IMDSv2 | Launch template / node group `metadata_options.http_tokens = "required"` and `http_put_response_hop_limit = 1` | [AWS — IMDSv2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html) |
| Network policy CNI | `aws_eks_addon` for `vpc-cni` with `ENABLE_NETWORK_POLICY: "true"` configuration, or Cilium/Calico installed | [AWS — VPC CNI network policy](https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy.html) |

### GKE

| Checklist item | Terraform attribute | Source |
|---|---|---|
| Workload Identity | `resource "google_container_cluster" "*"` → `workload_identity_config.workload_pool` set | [GCP — Workload Identity](https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity) |
| Shielded nodes | `node_config.shielded_instance_config.enable_secure_boot = true` and `enable_integrity_monitoring = true` | [GCP — Shielded GKE Nodes](https://cloud.google.com/kubernetes-engine/docs/how-to/shielded-gke-nodes) |
| Private cluster | `private_cluster_config.enable_private_nodes = true`; `master_authorized_networks_config` populated | [GCP — Private clusters](https://cloud.google.com/kubernetes-engine/docs/concepts/private-cluster-concept) |
| Binary Authorization | `binary_authorization.evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"` | [GCP — Binary Authorization](https://cloud.google.com/binary-authorization/docs/overview) |
| Network policy | `network_policy.enabled = true` (Calico) or `datapath_provider = "ADVANCED_DATAPATH"` (Dataplane V2) | [GCP — Network policy](https://cloud.google.com/kubernetes-engine/docs/how-to/network-policy) |

### AKS

| Checklist item | Terraform attribute | Source |
|---|---|---|
| Workload Identity | `resource "azurerm_kubernetes_cluster" "*"` → `workload_identity_enabled = true`, `oidc_issuer_enabled = true` | [Azure — Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview) |
| Microsoft Defender | `microsoft_defender { log_analytics_workspace_id = … }` | [Azure — Defender for Containers](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-containers-introduction) |
| Azure RBAC + AAD integration | `azure_active_directory_role_based_access_control { azure_rbac_enabled = true }` | [Azure — AAD with AKS](https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac) |
| Network policy | `network_profile.network_policy = "calico"` or `"cilium"` | [Azure — Network policies](https://learn.microsoft.com/en-us/azure/aks/use-network-policies) |

### Cross-cloud: IRSA / Workload Identity trust scoping

This is the highest-leverage IaC finding. A correctly federated workload
identity is scoped to *one specific* ServiceAccount; a wildcard trust
policy is an account-wide privilege escalation.

```hcl
# CORRECT
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:payments-prod:payments-api"]   # exact
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}
```

```hcl
# WRONG — auditor FAILs this
condition {
  test     = "StringLike"            # << note the Like, not Equals
  variable = "...:sub"
  values   = ["system:serviceaccount:*"]   # << wildcard
}
```

The verifier:

1. Reads every `ServiceAccount` manifest in scope; collects the
   `eks.amazonaws.com/role-arn` annotation (or GCP's
   `iam.gke.io/gcp-service-account`, or Azure's
   `azure.workload.identity/client-id`).
2. Reads every `aws_iam_role` / `google_service_account_iam_binding` /
   federated credential in the Terraform.
3. Cross-checks that the role's trust scope matches the *exact*
   `system:serviceaccount:<ns>:<name>`, with no `StringLike` and no `*`.

---

## 3. GitOps repo checks

### Argo CD

| Item | Field to check |
|---|---|
| Sync strategy explicit | `spec.syncPolicy.syncOptions` includes `CreateNamespace=true` (when intentional), `PrunePropagationPolicy=foreground` |
| Auto-sync gated for prod | `spec.syncPolicy.automated` omitted or `prune=false` for prod, with manual sync window |
| Sync waves used | Resources annotated with `argocd.argoproj.io/sync-wave` for ordered rollouts (CRD before CR, namespace before workload) |
| Retry / backoff | `spec.syncPolicy.retry.limit`, `.backoff.duration`, `.backoff.factor`, `.backoff.maxDuration` set |
| Health checks customized for CRDs | `ConfigMap argocd-cm` `resource.customizations` covering operator-installed CRDs |
| `ApplicationSet` generators bounded | Cluster-generator or list-generator, never `git-files` against an open path on prod |

Source: [Argo CD — Application spec](https://argo-cd.readthedocs.io/en/stable/operator-manual/argocd-cm-yaml/), [Sync waves](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/).

### Flux

| Item | Field to check |
|---|---|
| `Kustomization.spec.prune` set deliberately | `true` for owned scope, `false` for shared ns |
| `Kustomization.spec.timeout` set | Default of 5m too short for some CRDs; bump for operators |
| `HelmRelease.spec.install.remediation` and `.upgrade.remediation` | `retries: 3`, `remediateLastFailure: true` |
| Image automation | `ImageRepository`, `ImagePolicy`, `ImageUpdateAutomation` are wired up but **only on dev/staging branches**; prod gates on PR review |
| Sources verified | `GitRepository.spec.verify.mode = "head"` with a `secretRef` to GPG keys, or `signing` via cosign |

Source: [Flux — Kustomization API](https://fluxcd.io/flux/components/kustomize/kustomizations/), [Flux — HelmRelease API](https://fluxcd.io/flux/components/helm/helmreleases/).

### Promotion pattern

The verifier asks the user (once) for the promotion pattern:

- **App-of-apps with environment branches** — dev/staging/main; PR-promotes
  by merging.
- **Kustomize overlays** — `overlays/{dev,staging,prod}/kustomization.yaml`
  with shared base.
- **Helm chart per env values** — `values-{dev,staging,prod}.yaml`.

It then verifies the prod overlay is **strict** (no `latest`, replicas
explicit, all probes present) and the dev overlay is **lax**
(autoscaling optional, mTLS optional).

---

## 4. Observability IaC checks

(Called by the `observability-auditor` subagent.)

| Item | Where to check |
|---|---|
| OTel Collector deployed | Terraform `helm_release` for `opentelemetry-collector`, or a `Deployment`/`DaemonSet` manifest. Both agent + gateway tiers expected for tail sampling. |
| Prometheus exemplar storage enabled | `--enable-feature=exemplar-storage` in Prometheus args (Helm chart values) |
| Trace backend deployed | Tempo / Jaeger / Grafana Cloud secret + datasource configured |
| Loki / log backend configured to index `trace_id` | Helm values for Loki include `trace_id` in the `pipeline_stages` regex |
| Alertmanager routes mapped to severity labels | Tier-1 `severity: page` routes to PagerDuty / Opsgenie; `severity: ticket` routes to Jira |
| SLO recording rules per workload | A `PrometheusRule` per workload with the four windows (5m, 30m, 1h, 6h) |

---

## 5. Reporting shape

When asked for an IaC compliance summary the skill produces a table:

```text
| Tier   | Item                                | Source                        | Verdict | Evidence             |
|--------|-------------------------------------|-------------------------------|---------|----------------------|
| EKS    | etcd KMS encryption                 | aws_eks_cluster.main          | PASS    | eks.tf:42            |
| EKS    | Audit log to CloudWatch             | enabled_cluster_log_types     | FAIL    | eks.tf:55            |
| IAM    | IRSA trust StringLike wildcard      | iam-payments.tf               | FAIL    | iam-payments.tf:18   |
| AppNS  | pod-security.kubernetes.io/enforce  | namespaces/payments-prod.yaml | PASS    | namespaces/...:7     |
| ArgoCD | Auto-sync prune=true on prod        | apps/payments-prod.yaml       | WARN    | apps/...:23          |
```

Each row's `Evidence` is a `file:line` so the user can navigate directly to
the source of the finding.
