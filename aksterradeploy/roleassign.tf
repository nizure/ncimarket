# locals {
#   node_resource_group_id = format("%s/resourceGroups/%s", data.azurerm_subscription.current.id, azurerm_kubernetes_cluster.aks_cluster.node_resource_group)
# }

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "clientcfg" {
}

resource "azurerm_role_assignment" "aks_cluster_sa_network_contributor" {
  #   scope                = azurerm_virtual_network.demo.id
  scope                = module.vnet.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity.0.principal_id
}

resource "azurerm_role_assignment" "kubelet_managed_id_operator" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id
}


resource "azurerm_role_assignment" "acr_image_puller" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "acr_reader" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id
}


data "azurerm_user_assigned_identity" "agentpool" {
  name                = "${azurerm_kubernetes_cluster.aks_cluster.name}-agentpool"
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  depends_on          = [azurerm_kubernetes_cluster.aks_cluster]
}

data "azurerm_resource_group" "node_rg" {
  name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group

}

resource "azurerm_role_assignment" "agentpool_msi" {
  scope                            = data.azurerm_resource_group.node_rg.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = data.azurerm_user_assigned_identity.agentpool.principal_id
  skip_service_principal_aad_check = true

}

resource "azurerm_role_assignment" "agentpool_vm" {
  scope                            = data.azurerm_resource_group.node_rg.id
  role_definition_name             = "Virtual Machine Contributor"
  principal_id                     = data.azurerm_user_assigned_identity.agentpool.principal_id
  skip_service_principal_aad_check = true
}
