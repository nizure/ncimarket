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

# data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-aks-rg"
  location = var.location
  tags = {
    environment = var.env
  }
}

