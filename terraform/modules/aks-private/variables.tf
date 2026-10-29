variable "name" {
  description = "Cluster name."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "kubernetes_version" {
  description = "Pinned AKS version; null lets Azure pick the default."
  type        = string
  default     = null
}

variable "node_subnet_id" {
  description = "Spoke subnet for the node pools."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Central privatelink.<region>.azmk8s.io zone, usually in the hub subscription."
  type        = string
}

variable "cluster_identity_id" {
  description = "User-assigned identity of the control plane (needs Network and Private DNS Zone Contributor)."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Entra ID groups with cluster-admin rights."
  type        = list(string)
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "system_pool" {
  type = object({
    vm_size   = string
    min_count = number
    max_count = number
    zones     = list(string)
  })
  default = {
    vm_size   = "Standard_D4ds_v5"
    min_count = 1
    max_count = 3
    zones     = ["1", "2", "3"]
  }
}

variable "user_pools" {
  description = "Additional node pools keyed by name."
  type = map(object({
    vm_size   = string
    min_count = number
    max_count = number
    zones     = list(string)
    labels    = optional(map(string), {})
    taints    = optional(list(string), [])
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
