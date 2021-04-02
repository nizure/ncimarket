terraform {
    reauired_version = ">= 0.14.8"
    backend "azurerm" {}
}

provider "azurerm" {
    version = "~> 2.51.0"
    features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-aks-rg"
  location = var.location
  tags = {
    environment = "${var.env}"
  }
}

