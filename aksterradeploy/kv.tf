# data "azurerm_key_vault" "mkv" {
#   name                = var.kv-name
#   resource_group_name = var.kv-rg

# }
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "kv" {
  name                = "${var.env}kv"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}


resource "azurerm_user_assigned_identity" "podIdentity" {
  resource_group_name = module.aks.node_resource_group
  location            = var.location
  name                = "${var.env}podIdentity"
  tags                = var.tags
  depends_on          = [module.aks]
}

resource "azurerm_key_vault_access_policy" "podIdentity_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_subscription.current.tenant_id
  object_id    = azurerm_user_assigned_identity.podIdentity.principal_id

  secret_permissions = [
    "get",
  ]
  depends_on = [module.aks]

}

# Install Secrets Store CSI Driver and Azure Provider 

resource "helm_release" "kv_csi" {
  name       = "csi-secrets-provider-azure"
  repository = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
  chart      = "csi-secrets-store-provider-azure"
  namespace  = "kube-system"
  depends_on = [module.aks]
}