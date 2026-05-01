# Terraform best-practices cheatsheet (fallback)

Use this when the `terraform-skill` skill is not installed. It's a condensed version of the canonical guidance — for the full text, install Anton Babenko's terraform-skill (Apache-2.0).

## Module hierarchy

| Tier | Purpose | Example |
|---|---|---|
| **Resource** | Single logical group | VPC + subnets, SG + rules |
| **Resource module / primitive** | Reusable wrapper of one logical group | `modules/primitives/vpc` |
| **Infrastructure / composed** | Multiple primitives wired for a purpose | `modules/composed/network-baseline` |
| **Composition / root** | Complete environment | `environments/prod/main.tf` |
| **Linking module** | Cross-account / cross-project glue | `modules/links/peering` |

## File layout per module

```
my-module/
├── README.md
├── main.tf          # Resources / module calls (locals at top)
├── variables.tf     # Inputs with description + type + validation
├── outputs.tf       # Outputs with description (sensitive where needed)
├── versions.tf      # required_version + required_providers
├── examples/
│   ├── minimal/
│   └── complete/
└── tests/
    └── *.tftest.hcl
```

## Variable hygiene — minimum bar

```hcl
variable "environment" {
  description = "Environment name. Used for tagging and naming."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }

  nullable = false
}
```

- `description` — always.
- `type` — always; never `any` or `map(any)`.
- `validation` — for any constrained input (enums, regex, ranges).
- `nullable = false` — for required strings.
- `sensitive = true` — for secrets and any input that ends up in logs.
- `default` — only when the default is genuinely safe in production.

## Output hygiene

```hcl
output "cluster" {
  description = "Connection descriptor for the cluster."
  value = {
    endpoint = google_container_cluster.this.endpoint
    ca_cert  = google_container_cluster.this.master_auth[0].cluster_ca_certificate
    name     = google_container_cluster.this.name
  }
  sensitive = true  # ca_cert is sensitive
}
```

- Return structured objects when several values describe one thing.
- Mark `sensitive = true` when any field is sensitive (the whole output gets the marker).
- Always include `description`.
- Don't echo inputs back (`value = var.x` with no transformation).

## Block ordering (resources)

1. `count` or `for_each` (meta-arg, blank line after)
2. `provider = ...` (meta-arg)
3. Other arguments
4. `tags` / `labels` (last real arg)
5. `depends_on`
6. `lifecycle`

## Count vs for_each

- `count = X ? 1 : 0` for a single boolean toggle.
- `for_each = toset(...)` or `for_each = { for ... }` whenever items have stable names. Removing one item in a count list reshuffles indices and triggers spurious recreates.

## Locals for dependency hints

```hcl
locals {
  vpc_id = try(
    aws_vpc_ipv4_cidr_block_association.this[0].vpc_id,
    aws_vpc.this.id
  )
}
```

Forces the right deletion order without explicit `depends_on`.

## Provider aliases for cross-scope modules

```hcl
# versions.tf
terraform {
  required_providers {
    google = {
      source                = "hashicorp/google"
      version               = "~> 6.14"
      configuration_aliases = [google.host, google.service]
    }
  }
}

# main.tf
resource "google_compute_shared_vpc_host_project" "host" {
  provider = google.host
  project  = var.host_project_id
}

resource "google_compute_shared_vpc_service_project" "svc" {
  provider        = google.service
  host_project    = var.host_project_id
  service_project = var.service_project_id
}
```

Without `configuration_aliases`, the module silently inherits the caller's default provider — meaning your audit must flag any cross-scope module that lacks aliases.

## Modern Terraform features (1.0+)

| Feature | Version | Use |
|---|---|---|
| `try()` | 0.13+ | Safe fallbacks |
| `nullable = false` | 1.1+ | Reject null on required inputs |
| `moved` blocks | 1.1+ | Refactor without destroy/recreate |
| `optional()` with default | 1.3+ | Optional object attributes |
| Native `terraform test` | 1.6+ | `*.tftest.hcl` |
| Mock providers | 1.7+ | Cost-free unit tests |
| Provider functions | 1.8+ | `provider::aws::trim_iam_role_path(...)` |
| Cross-variable validation | 1.9+ | `validation` block can reference other `var.X` |
| Write-only arguments (ephemeral) | 1.11+ | Secrets never persisted in state |

## Version constraints

- Terraform: `required_version = "~> 1.9"` (pin minor, allow patches).
- Providers: `version = "~> 6.14"` (pin major, allow minor + patch).
- Modules in prod root: pin exact version.
- Modules in dev root: `~> X.Y`.

## Anti-patterns to flag

- `version = ">= 5.0"` — uncapped major (will accept 7.0, breaks).
- `version = "5.1.2"` exact-pin in a library module — inflexible for callers.
- `required_version` missing entirely — silent acceptance of any TF version.
- Missing `required_providers` block — provider inheritance is silent.
- `provider "X" {}` blocks **inside reusable modules** — anti-pattern; modules should only declare `required_providers`, never instantiate providers (Terraform will warn).
