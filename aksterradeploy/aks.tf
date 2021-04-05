resource "azurerm_container_registry" "acr" {
  name                = "${var.env}acreg"
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
  # private_cluster_enabled         = false
  # sku_tier                        = var.sku_tier

  default_node_pool {
    name                = "${var.env}pool" //substr(var.system_node_pool.name, 0, 12)
    vm_size             = var.vm_size
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = true
    max_count           = var.max_node
    min_count           = var.min_node
    os_disk_size_gb     = var.os_size
    type                = "VirtualMachineScaleSets"
    vnet_subnet_id      = module.vnet.vnet_subnets[0]


    tags = {
      "environment" = var.env
      "nodepoolos"  = "linux"
      "app"         = "system-apps"
    }
  }
  addon_profile {
    azure_policy { enabled = true }

    http_application_routing { enabled = true }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.logspaceid
    }
  }

  # Identity (System Assigned or Service Principal)
  identity {
    type = "SystemAssigned"
  }

  # RBAC and Azure AD Integration Block
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed                = true
      admin_group_object_ids = var.azure_ad_admin_groups
    }
  }
  # Network Profile
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "Standard"
  }

  tags = {
    Environment = "dev"
  }
}

resource "kubernetes_cluster_role_binding" "aad_integration" {
  metadata {
    name = "${var.env}admins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "Group"
    name      = var.aks-aad-clusteradmins
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}

# Allows all get list of namespaces, otherwise tools like 'kubens' won't work
resource "kubernetes_cluster_role" "all_can_list_namespaces" {
  depends_on = [azurerm_kubernetes_cluster.k8s]
  for_each   = true ? toset(["ad_rbac"]) : []
  metadata {
    name = "list-namespaces"
  }

  rule {
    api_groups = ["*"]
    resources = [
      "namespaces"
    ]
    verbs = [
      "list",
    ]
  }
}



resource "kubernetes_cluster_role_binding" "all_can_list_namespaces" {
  depends_on = [azurerm_kubernetes_cluster.k8s]
  for_each   = true ? toset(["ad_rbac"]) : []
  metadata {
    name = "authenticated-can-list-namespaces"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.all_can_list_namespaces[each.key].metadata.0.name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "system:authenticated"
  }
}