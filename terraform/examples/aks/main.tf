provider "azurerm" {
  features {}
}

variable "acr_id" {
  type = string
}

module "aks" {
  source = "../../modules/aks-private"

  name                       = "aks-demo-weu-01"
  resource_group_name        = "rg-demo-aks-weu-01"
  location                   = "westeurope"
  node_subnet_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-demo-net/providers/Microsoft.Network/virtualNetworks/vnet-demo/subnets/snet-aks"
  private_dns_zone_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-dns/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
  cluster_identity_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-demo-aks-weu-01/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-aks-demo"
  admin_group_object_ids     = ["00000000-0000-0000-0000-000000000000"]
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-demo-mon/providers/Microsoft.OperationalInsights/workspaces/law-demo"

  user_pools = {
    apps = { vm_size = "Standard_D4ds_v5", min_count = 1, max_count = 5, zones = ["1", "2", "3"] }
  }

  tags = { environment = "demo", managed_by = "terraform" }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_object_id
}
