data "azurerm_resource_group" "aks_node_rg" {
  name = module.aks.node_resource_group
}

resource "azurerm_role_assignment" "aks_mi_role_assignment" {
  scope                = module.vnet.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.system_assigned_identity.0.principal_id
}

resource "azurerm_role_assignment" "all_mi_operator" {
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "acr_image_puller" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "acr_reader" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "Reader"
  principal_id         = module.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "agentpool_msi" {
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = module.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true

}

resource "azurerm_role_assignment" "agentpool_vm" {
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name             = "Virtual Machine Contributor"
  principal_id                     = module.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}
