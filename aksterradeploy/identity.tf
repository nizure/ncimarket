# https://github.com/syedhassaanahmed/tf-aks-kv/blob/master/main.tf
# https://github.com/msalemcode/aks-terraform-pod-identity/blob/master/terraform_aks/namespace-pod-identity.tf
# https://registry.terraform.io/modules/Azure/aks/azurerm/latest?tab=outputs

data "azurerm_key_vault" "mkv" {

  name                = var.kv-name
  resource_group_name = azurerm_resource_group.rg.name

}

#Adding namespace
resource "kubernetes_namespace" "nsl" {
  metadata {
    name = "helom"
  }
  depends_on = [module.aks]
}


# User Assigned Identities 
resource "azurerm_user_assigned_identity" "podIdentity" {
  resource_group_name = module.aks.node_resource_group
  location            = var.location
  name                = "${var.env}podIdentity"
  tags                = var.tags
  depends_on          = [module.aks]
}


resource "azurerm_key_vault_access_policy" "podIdentity_access_policy" {
  key_vault_id = data.azurerm_key_vault.mkv.id
  tenant_id    = data.azurerm_subscription.current.tenant_id
  object_id    = azurerm_user_assigned_identity.podIdentity.principal_id

  secret_permissions = [
    "get",
  ]
  depends_on = [module.aks]

}


locals {
  settings = {
    fullname     = var.aad_ns
    key_vault_id = data.azurerm_key_vault.mkv.id
    tenant_id    = data.azurerm_subscription.current.tenant_id
    environment  = var.env
    managedIdentity = {
      selectorName = var.aad_ns
      resourceId   = azurerm_user_assigned_identity.podIdentity.id
      clientId     = azurerm_user_assigned_identity.podIdentity.client_id

    }

    ## for the demo - hardcode the values
    secret1 = "appInsightKey"
    secret2 = "cosmosdbKey"


  }
}

resource "helm_release" "azureIdenity" {
  name         = var.aad_ns
  chart        = "./helm"
  namespace    = var.aad_ns
  max_history  = 4
  atomic       = true
  reuse_values = false
  timeout      = 1800
  values       = [yamlencode(local.settings)]
  depends_on   = [module.aks]

}

