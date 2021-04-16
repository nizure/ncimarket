resource "azurerm_container_registry" "acr" {
  name                = "${var.env}acreg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

module "aks" {
  source              = "Azure/aks/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  # client_id                        = "your-service-principal-client-appid"
  # client_secret                    = "your-service-principal-client-password"
  kubernetes_version               = var.kubversion
  orchestrator_version             = var.kubversion
  prefix                           = var.env
  network_plugin                   = "azure"
  network_policy                   = "azure"
  vnet_subnet_id                   = module.vnet.vnet_subnets[0]
  os_disk_size_gb                  = var.os_size
  sku_tier                         = "Paid" # defaults to Free
  enable_role_based_access_control = true
  rbac_aad_admin_group_object_ids  = var.azure_ad_admin_groups //[data.azuread_group.aks_cluster_admins.id]  #Object ID of groups with admin access.
  rbac_aad_managed                 = true
  private_cluster_enabled          = false
  enable_log_analytics_workspace   = true
  enable_http_application_routing  = true
  enable_azure_policy              = true
  enable_auto_scaling              = true
  agents_min_count                 = var.min_node
  agents_max_count                 = var.max_node
  agents_count                     = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 100
  agents_pool_name                 = "exnodepool"
  agents_availability_zones        = ["1", "2", "3"]
  agents_type                      = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  depends_on = [module.vnet]
}

# resource "azurerm_kubernetes_cluster_node_pool" "nodepool" {
#   lifecycle {
#     ignore_changes = [
#       node_count
#     ]
#   }
#   for_each = var.additional_node_pools
#   kubernetes_cluster_id = module.aks.aks_id
#   name                  = each.value.node_os == "Windows" ? substr(each.key, 0, 6) : substr(each.key, 0, 12)
#   node_count            = each.value.node_count
#   vm_size               = each.value.vm_size
#   availability_zones    = each.value.zones
#   max_pods              = 250
#   os_disk_size_gb       = 128
#   os_type               = each.value.node_os
#   vnet_subnet_id        = module.vnet.vnet_subnets[4]
#   node_taints           = each.value.taints
#   enable_auto_scaling   = each.value.cluster_auto_scaling
#   min_count             = each.value.cluster_auto_scaling_min_count
#   max_count             = each.value.cluster_auto_scaling_max_count
#   depends_on = [module.aks]
# }


