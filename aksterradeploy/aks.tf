resource "azurerm_container_registry" "acr" {
  name                = "${var.env}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}


resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.env}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.env}-aks"

  default_node_pool {
    name                 = "systempool"
    vm_size              = var.vm_size
    availability_zones   = [1, 2, 3]
    enable_auto_scaling  = true
    max_count            = var.max_node
    min_count            = var.min_node
    os_disk_size_gb      = 50
    type                 = "VirtualMachineScaleSets"
    vnet_subnet_id       = module.vnet.vnet_subnets[0]

   tags = {
      "environment"      = var.env
      "nodepoolos"       = "linux"
      "app"              = "system-apps" 
   } 
  }

# Identity (System Assigned or Service Principal)
  identity {
    type = "SystemAssigned"
  }

# Add On Profiles
  # addon_profile {
  #   azure_policy {enabled =  true}
  #   oms_agent {
  #     enabled =  true
  #     log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  #   }
  # }

# RBAC and Azure AD Integration Block
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      admin_group_object_ids = var.azure_ad_admin_groups
    }
  }

# Network Profile
  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "Standard"
  }

  tags = {
    Environment = "dev"
  }

}