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


