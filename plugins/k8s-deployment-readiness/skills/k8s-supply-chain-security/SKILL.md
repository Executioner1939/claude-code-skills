---
name: k8s-supply-chain-security
internal: true
---

# Kubernetes supply chain & runtime security

**Audience:** internal — loaded only by the `deployment-verifier` subagent.

This skill covers the LearnKube "Your Security" section: Pod Security
Standards, RBAC, NetworkPolicy, image provenance, admission control,
workload identity, and external secrets.

---

## 1. Pod Security Standards

Source: [Kubernetes — Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) and [Enforcing PSS with the admission controller](https://kubernetes.io/docs/concepts/security/pod-security-admission/).

The PodSecurityPolicy API was removed in v1.25. The replacement is the
built-in Pod Security admission controller, which enforces one of three
profiles per namespace via labels.

| Profile | Used for | What it prohibits |
|---|---|---|
| **Privileged** | System / infra workloads only. | Nothing. |
| **Baseline** | Default for application workloads. | `hostNetwork`, `hostPID`, `hostIPC`, privileged containers, `hostPath` volumes, dangerous capabilities, untrusted SELinux profiles, `Unconfined` seccomp. |
| **Restricted** | Hardened workloads. | Baseline plus: must `runAsNonRoot`, `allowPrivilegeEscalation: false`, drop `ALL` capabilities (and add back only `NET_BIND_SERVICE` when needed), define a non-`Unconfined` `seccompProfile`, restrict volume types. |

Per the upstream doc: *"These policies are cumulative and range from
highly-permissive to highly-restrictive."*

### Namespace enforcement labels

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: payments-prod
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

- `enforce` — blocks non-compliant pods at admission.
- `audit` — records violations in audit log but allows the pod.
- `warn` — returns a warning to the user but allows the pod.

### Required securityContext for Restricted

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 65532              # nobody-equivalent; not 0
  fsGroup: 65532
  seccompProfile:
    type: RuntimeDefault
containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
        add: ["NET_BIND_SERVICE"]   # only if binding < 1024
```

### What the verifier flags

- Production-tier namespace without `pod-security.kubernetes.io/enforce` →
  **FAIL**.
- `enforce: privileged` outside `kube-system`-style namespaces → **FAIL**.
- `readOnlyRootFilesystem: false` or unset → **WARN**. Most apps can run
  read-only; writes go to `emptyDir` volumes mounted at `/tmp`.
- `runAsUser: 0`, `runAsNonRoot: false`, or unset on a production workload
  → **FAIL**.
- Capabilities `drop: ALL` missing → **FAIL**.

---

## 2. ServiceAccount and RBAC

Source: [Kubernetes — Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) and the [Secrets best practices](https://kubernetes.io/docs/concepts/security/secrets-good-practices/) page.

### Default ServiceAccount is a bug

Every namespace ships with a `default` ServiceAccount. Pods without a
`serviceAccountName` use it. If anything ever grants `default` a Role, every
pod in the namespace inherits it — including pods that should have no API
access whatsoever.

The fix is one ServiceAccount per workload, scoped to that workload's
needs:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api
  namespace: payments-prod
automountServiceAccountToken: false   # turn off unless the app actually calls the API
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: api-config-reader
  namespace: payments-prod
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["api-feature-flags"]   # name-scoped
    verbs: ["get", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: api-config-reader
  namespace: payments-prod
subjects:
  - kind: ServiceAccount
    name: api
roleRef:
  kind: Role
  name: api-config-reader
  apiGroup: rbac.authorization.k8s.io
```

### What the verifier flags

- Pod uses ServiceAccount `default` (explicit or implicit) → **FAIL**.
- `automountServiceAccountToken: true` (or unset, which defaults to true) on
  a workload whose code does not call the Kubernetes API → **WARN**. Find
  out by grepping for clients: `kubernetes/client-go`, `@kubernetes/client-node`,
  `kubernetes` Python package, `kube` Rust crate.
- `ClusterRoleBinding` to a workload-scoped ServiceAccount → **WARN**. The
  bias should be namespace-scoped Roles.
- Verbs `*` or `resources: ["*"]` on any application workload → **FAIL**.

---

## 3. NetworkPolicy

Source: [Kubernetes — Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) and [CNCF cluster hardening guide](https://www.cisecurity.org/benchmark/kubernetes).

Without NetworkPolicy, every pod can reach every other pod in the cluster on
every port. This is "everything in one collision domain" — a compromised
nginx exec sidecar can hit the payments database directly.

The pattern: **default-deny** per namespace, then explicit allow-rules per
workload.

```yaml
# default deny-all in the namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: payments-prod
spec:
  podSelector: {}
  policyTypes: ["Ingress", "Egress"]
---
# allow DNS (without this, nothing resolves)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: payments-prod
spec:
  podSelector: {}
  policyTypes: ["Egress"]
  egress:
    - to:
        - namespaceSelector:
            matchLabels: { kubernetes.io/metadata.name: kube-system }
          podSelector:
            matchLabels: { k8s-app: kube-dns }
      ports:
        - port: 53
          protocol: UDP
        - port: 53
          protocol: TCP
---
# allow the api → db connection
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-to-db
  namespace: payments-prod
spec:
  podSelector:
    matchLabels: { app: db }
  policyTypes: ["Ingress"]
  ingress:
    - from:
        - podSelector:
            matchLabels: { app: api }
      ports:
        - port: 5432
          protocol: TCP
```

### What the verifier flags

- Namespace with workloads but no default-deny NetworkPolicy → **FAIL**.
- Default-deny without a DNS allow-rule → **FAIL** (everything will appear
  broken).
- `ipBlock` allowing `0.0.0.0/0` on an egress rule of a payments/PII
  workload → **WARN**.

CNI requirement: Network policies require a CNI plugin that supports them
(Cilium, Calico, weave-net, AWS VPC CNI with policy mode). The verifier
checks the cluster's CNI when scanning IaC (see
[`k8s-iac-compliance`](../k8s-iac-compliance/SKILL.md)) and flags policy
manifests targeting a cluster whose CNI ignores them.

---

## 4. Image provenance

Source: [Kubernetes — Images](https://kubernetes.io/docs/concepts/containers/images/) and [Sigstore / cosign](https://docs.sigstore.dev/).

### What "scanned and pulled from a trusted registry" decomposes into

1. **Stable, content-addressable tag.** Either a semver tag (`v1.4.7`) or
   the immutable image digest (`@sha256:…`). `:latest` is rejected outright
   — what the cluster ran yesterday and what it runs today are not the same
   bits, and you cannot reproduce a rollback.

2. **Pulled from a registry the cluster trusts.** Public Docker Hub or
   `quay.io` is acceptable for inner-dev, never for production. Production
   should pull from a registry that is:
   - Inside the trust boundary (ECR/Artifact Registry/ACR in the same
     account/project/tenant), or
   - Mirrored from an external source with a known supply-chain pipeline
     (provenance attestation + signature verification at admission).

3. **Scanned for CVEs.** Trivy/Grype/Snyk in CI; results pushed to the
   registry as attestations. The admission controller (Kyverno, OPA
   Gatekeeper, Connaisseur, Sigstore policy-controller) rejects an image
   without a recent passing scan.

4. **Signed.** The image is signed (cosign) with a key the admission
   controller verifies. This blocks an attacker who can push to the
   registry but not sign.

```yaml
# Kyverno policy: only allow signed images from approved registries
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-image-signature
spec:
  validationFailureAction: Enforce
  rules:
    - name: verify-signature
      match:
        any:
          - resources:
              kinds: ["Pod"]
      verifyImages:
        - imageReferences:
            - "ghcr.io/myorg/*"
            - "*.dkr.ecr.us-east-1.amazonaws.com/*"
          attestors:
            - entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      ...
                      -----END PUBLIC KEY-----
```

### What the verifier flags

- Any `:latest` reference → **FAIL**.
- Any tag without a digest pin for tier-1 production workloads → **WARN**
  (tags are mutable in most registries — defense in depth is the digest).
- `imagePullPolicy: Always` plus mutable tag → **WARN** (you'll get a
  different image on every pod restart).
- Image registry that does not match the cluster's allowlist → **FAIL**.

---

## 5. Admission control

Source: [Kubernetes — Admission Controllers Reference](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/).

Pod Security admission, image signature verification, and most
organization-specific rules ("every namespace must have a cost-center
label", "no service of type LoadBalancer in dev") are enforced by
**ValidatingAdmissionPolicy** (CEL, built-in since v1.30) or by an external
controller (Kyverno, OPA Gatekeeper).

The verifier checks that the *target cluster* has:

- Pod Security Admission enabled (it is on by default since v1.25, but
  enforcement requires the namespace label — checked in §1).
- Either ValidatingAdmissionPolicy resources OR a Kyverno/Gatekeeper
  installation, for org-specific rules.
- Image policies that block unsigned or unscanned images on tier-1
  namespaces.

When scanning IaC, the verifier looks for the controller install in the
GitOps repo (Helm release for `kyverno`, `gatekeeper-system`, `policy-controller`,
or the corresponding Terraform `helm_release`).

---

## 6. Workload identity for cloud resources

Source: [AWS — IAM Roles for Service Accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html), [GCP — Workload Identity](https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity), [Azure — Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview).

The forbidden patterns:

- **Long-lived static credentials in a Secret.** A `aws_access_key_id` /
  `aws_secret_access_key` pair in a Secret can be exfiltrated by anyone
  with `get secret` in the namespace and is valid until manually rotated.
- **Node-attached IAM roles.** All pods on the node share the node's role;
  any pod with `hostNetwork` or that talks to the EC2 metadata service gets
  the role. This is the breach pattern behind multiple high-profile
  incidents.

The correct pattern federates a per-workload ServiceAccount to a cloud
identity via OIDC:

```yaml
# IRSA example
apiVersion: v1
kind: ServiceAccount
metadata:
  name: payments-api
  namespace: payments-prod
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::111122223333:role/payments-api
---
# In Terraform (assume-role policy fragment)
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
      values   = ["system:serviceaccount:payments-prod:payments-api"]
    }
  }
}
```

The IaC verifier (see [`k8s-iac-compliance`](../k8s-iac-compliance/SKILL.md))
cross-checks that the `eks.amazonaws.com/role-arn` annotation on every
ServiceAccount points to a role whose trust policy is scoped to that
specific `system:serviceaccount:<ns>:<name>` — not `*`, not the namespace.

---

## 7. External secret store

Source: [External Secrets Operator](https://external-secrets.io/), [HashiCorp Vault Agent Injector](https://developer.hashicorp.com/vault/docs/platform/k8s/injector).

Native Kubernetes Secrets are base64-encoded blobs in etcd. By default etcd
is not encrypted at rest unless the cluster admin configured a [KMS
provider](https://kubernetes.io/docs/tasks/administer-cluster/kms-provider/) —
and even then, anyone with `get secret` in the namespace sees plaintext.

The production posture is:

- Secrets live in Vault / AWS Secrets Manager / GCP Secret Manager / Azure
  Key Vault.
- Either External Secrets Operator (sync to a native Secret, app reads the
  file/env normally) or a sidecar/init pattern (Vault Agent Injector,
  cloud-specific SDK) fetches them at pod start.
- The cluster's etcd is KMS-encrypted regardless.

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-creds
  namespace: payments-prod
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: db-creds
    creationPolicy: Owner
  data:
    - secretKey: username
      remoteRef:
        key: secret/data/payments/db
        property: username
    - secretKey: password
      remoteRef:
        key: secret/data/payments/db
        property: password
```

### What the verifier flags

- `kind: Secret` with literal `data` or `stringData` checked into git (not
  sealed-secrets, not SOPS-encrypted, not External Secrets references) →
  **FAIL**.
- etcd KMS encryption not configured in the cluster IaC → **FAIL** for prod.
