terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.4.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

provider "azuread" {
  features {}
}

data "azurerm_subscription" "current" {}

# data "azurerm_kubernetes_cluster" "main" {
#   name                = "${var.env}-aks"
#   resource_group_name = azurerm_resource_group.rg.name
# }
resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-aks-rg"
  location = var.location
  tags = {
    environment = var.env
  }
}

provider "helm" {
  debug = true
  kubernetes {
    # load_config_file       = "false"
    host                   = module.aks.admin_host
    username               = module.aks.admin_username
    password               = module.aks.admin_password
    client_certificate     = base64decode(module.aks.admin_client_certificate)
    client_key             = base64decode(module.aks.admin_client_key)
    cluster_ca_certificate = base64decode(module.aks.admin_cluster_ca_certificate)
  }
}

# provider "helm" {
#   debug = true
#   kubernetes {
#     host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
#     username               = data.azurerm_kubernetes_cluster.main.kube_config.0.username
#     password               = data.azurerm_kubernetes_cluster.main.kube_config.0.password
#     client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
#     client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
#     cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
#   }
# }