# Landing-zone checklists by provider

Use the matching section based on what `versions.tf` declares. If multiple, run the audit per-cloud.

## GCP

- **VPC Service Controls** — `google_access_context_manager_*`, `_service_perimeter`, `_access_level`.
- **Access Context Manager** — perimeter + access policy + access level for BeyondCorp / device-trust.
- **Folder-level IAM** — `google_folder_iam_member` / `_binding`. Folder primitive without IAM is a half-implementation.
- **Org-level IAM** — `google_organization_iam_member` / `_binding`. Group-to-role mapping at org.
- **Workload Identity Federation pool + provider** — `google_iam_workload_identity_pool` / `_provider`. CI cannot federate without it; absence forces SA keys (which security-baseline modules then forbid → self-contradiction).
- **Hierarchical firewall policies** — `google_compute_organization_security_policy` / `google_compute_firewall_policy`. Distinct from network-scoped `google_compute_network_firewall_policy`.
- **Tag-based IAM and tag-based org policies** — `google_tags_tag_key` / `_tag_value` / `_tag_binding`. The modern pattern.
- **Project factory pattern** — `project` primitive must support per-project budget, default-SA removal, default-network deletion, OS Login enforcement, default IAM, API enablement.
- **Host vs service project distinction** — both must be modeled at the composed layer; service projects need a "service-project" composition that attaches to a remote host.
- **Private Service Connect** — `google_compute_service_attachment`, `google_compute_forwarding_rule` for PSC.
- **Private Service Access (PSA)** — `google_compute_global_address` + `google_service_networking_connection` for Cloud SQL / Memorystore private IPs.
- **IAP / BeyondCorp** — `google_iap_brand`, `google_iap_tunnel_iam_member`. SSH-via-IAP is the canonical bastion-less pattern.
- **Security Command Center enrollment** — `google_scc_notification_config`, `google_scc_source`, `google_scc_organization_settings`.
- **Essential Contacts** — `google_essential_contacts_contact`. Required for billing/legal/security notifications.
- **Cloud Armor** — `google_compute_security_policy`.
- **Certificate Manager** — `google_certificate_manager_certificate` / `_map` / `_dns_authorization`.
- **Log analytics buckets** — `google_logging_project_bucket_config` with `analytics_enabled = true`. The new pattern that replaces BQ-sink-as-archive for most cases.
- **Data Access audit log config** — `google_organization_iam_audit_config`. Without it, you log Admin Activity only.
- **DNS policy** — `google_dns_policy` for forwarding/logging.
- **Org-/folder-level budget** — `google_billing_budget` with empty `projects` filter or folder-scoped filter.
- **CMEK on log archive** — `google_storage_bucket` for log sinks must use `encryption.default_kms_key_name`.
- **Locked retention on log archive** — `retention_policy { is_locked = true }` for compliance.

## AWS

- **AWS Organizations + SCPs** — `aws_organizations_organization`, `aws_organizations_organizational_unit`, `aws_organizations_policy` (SERVICE_CONTROL_POLICY). Folder-tier IAM equivalent.
- **AWS Control Tower / Account Factory** — either Control Tower-managed accounts or `aws_organizations_account` factory pattern.
- **Identity Center (SSO)** — `aws_ssoadmin_*` resources. Permission sets, account assignments. Replaces direct IAM users.
- **CloudTrail org trail** — `aws_cloudtrail` with `is_organization_trail = true`, `is_multi_region_trail = true`, KMS-encrypted, log-file validation enabled.
- **AWS Config** — org-level `aws_config_organization_managed_rule` + conformance pack.
- **Security Hub** — `aws_securityhub_organization_admin_account` + `aws_securityhub_account` per member.
- **GuardDuty** — `aws_guardduty_organization_admin_account` + `aws_guardduty_organization_configuration`.
- **VPC + Transit Gateway / VPC Lattice** — TGW for hub-and-spoke; VPC Lattice for service-to-service across accounts.
- **VPC Endpoints (interface + gateway)** — for S3, DynamoDB, and every used AWS service.
- **PrivateLink** — `aws_vpc_endpoint_service` + `aws_vpc_endpoint` for cross-account service exposure.
- **IAM Identity Provider for OIDC** — `aws_iam_openid_connect_provider` for GitHub Actions / GitLab / etc. CI without this means SA keys.
- **Service Control Policies** — at minimum: deny-root, region restriction, deny-iam-user-creation, deny-leave-org.
- **KMS multi-region keys with rotation** — `aws_kms_key` with `multi_region = true`, `enable_key_rotation = true`.
- **S3 default encryption + Block Public Access at account level** — `aws_s3_account_public_access_block`.
- **Backup org-level** — `aws_backup_global_settings`, `aws_organizations_policy` of type BACKUP_POLICY.
- **Tag policies** — `aws_organizations_policy` of type TAG_POLICY.
- **Cost allocation tags + Budgets at org/OU level** — `aws_budgets_budget` with `cost_filters`.
- **Cross-account IAM roles for break-glass + audit** — `aws_iam_role` with org-wide trust.
- **Network Firewall** — `aws_networkfirewall_firewall_policy` for centralized inspection.

## Azure

- **Management Groups** — `azurerm_management_group` hierarchy. Folder equivalent.
- **Azure Policy + Initiatives** — `azurerm_policy_definition`, `_set_definition`, `_assignment` at MG level.
- **Subscription Vending pattern** — `azurerm_subscription` factory (requires EA / MCA / MPA agreement).
- **Hub-and-spoke with Virtual WAN** or classic hub-spoke — `azurerm_virtual_hub` + `_virtual_hub_connection`, or `azurerm_virtual_network` + peering + Azure Firewall hub.
- **Azure Firewall + Firewall Policy** — `azurerm_firewall_policy` at MG-relevant scope.
- **Private DNS Zones** — centralized in hub, linked to spokes via `azurerm_private_dns_zone_virtual_network_link`.
- **Private Endpoints + Private Link** — `azurerm_private_endpoint` for every PaaS.
- **Defender for Cloud** — `azurerm_security_center_subscription_pricing` per plan.
- **Sentinel** — `azurerm_sentinel_*` resources for SIEM.
- **Azure Monitor + Log Analytics workspace** — central workspace per tier, diagnostic settings forwarded.
- **Workload Identity Federation** — `azuread_application_federated_identity_credential` for GitHub Actions / GitLab.
- **Key Vault with HSM + soft-delete + purge protection** — `azurerm_key_vault` with `purge_protection_enabled = true`.
- **Resource locks at MG / subscription level** — `azurerm_management_lock`.
- **Tag inheritance via policy** — `Inherit a tag from the resource group if missing`.
- **Cost Management exports** — `azurerm_cost_management_export_resource_group`.
- **Activity log diagnostic settings** — forward to Log Analytics + Storage + Event Hub.

## OCI

- **Compartment hierarchy** — `oci_identity_compartment` nested, mirrors GCP folders.
- **Identity Domains** — `oci_identity_domains_*` for SSO / federation.
- **Tag namespaces + tag defaults** — `oci_identity_tag_namespace`, `_tag`, `oci_identity_tag_default`.
- **OCI Vault (KMS) with HSM** — `oci_kms_vault` with `vault_type = "VIRTUAL_PRIVATE"` for HSM.
- **Audit log retention per tenancy** — `oci_audit_configuration` with `retention_period_days` ≥ 365.
- **Cloud Guard** — `oci_cloud_guard_cloud_guard_configuration` enabled at root tenancy.
- **OS Management Hub + Vulnerability Scanning** — `oci_vulnerability_scans_host_scan_recipe`.
- **WAF + DDoS protection** — `oci_waf_web_app_firewall_policy`.
- **DRG + RPC for hub-and-spoke** — `oci_core_drg`, `_drg_attachment`, `_remote_peering_connection`.
- **Service Gateway + NAT Gateway** — every spoke.
- **Bastion service** — `oci_bastion_bastion`, replaces public bastion VMs.
- **Budget + alerts at compartment level** — `oci_budget_budget` with compartment scope.
- **Workload Identity for OKE → IAM** — instance-principal or workload-identity for OKE.

## Multi-cloud / cross-cloud

If the repo spans multiple clouds, cross-cloud linking is almost always missing:

- **DNS delegation** between clouds (e.g. GCP Cloud DNS subdomain delegated to AWS Route 53).
- **Federated identity** between clouds (e.g. AWS IAM role assumed by a GCP SA via OIDC).
- **VPN / Interconnect / Private connectivity** between clouds.
- **Shared artifact registry** that publishes from one cloud and is pulled by another.

These almost always live as untyped IDs passed between root modules. Recommend dedicated `links/` modules per cross-cloud relationship.
