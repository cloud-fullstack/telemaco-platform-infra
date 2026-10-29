resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = "Standard"

  # Private API server, resolved through the central private DNS zone.
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false
  private_dns_zone_id                 = var.private_dns_zone_id
  dns_prefix_private_cluster          = var.name

  # Identity: Entra ID only, no local accounts; pods use Workload Identity instead of secrets.
  local_account_disabled    = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  azure_policy_enabled      = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.cluster_identity_id]
  }

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_pool.vm_size
    auto_scaling_enabled         = true
    min_count                    = var.system_pool.min_count
    max_count                    = var.system_pool.max_count
    zones                        = var.system_pool.zones
    vnet_subnet_id               = var.node_subnet_id
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "systemtmp"
  }

  # Overlay networking: pod IPs do not consume spoke address space.
  # Egress goes through the hub firewall via the subnet route table.
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    outbound_type       = "userDefinedRouting"
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  monitor_metrics {}

  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 168

  tags = var.tags

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.user_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  mode                  = "User"
  vm_size               = each.value.vm_size
  auto_scaling_enabled  = true
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  zones                 = each.value.zones
  vnet_subnet_id        = var.node_subnet_id
  node_labels           = each.value.labels
  node_taints           = each.value.taints
  tags                  = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}

resource "azurerm_monitor_diagnostic_setting" "control_plane" {
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = ["kube-audit-admin", "kube-apiserver", "cluster-autoscaler", "guard"]
    content {
      category = enabled_log.value
    }
  }
}
