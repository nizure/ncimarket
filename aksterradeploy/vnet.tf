module "kool-vnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = "${var.env}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/23"]
  subnet_prefixes     = ["10.0.0.0/24", "10.0.1.0/24"]
  subnet_names        = ["${var.env}-app-subnet", "${var.env}-data-subnet"]

  subnet_service_endpoints = {
    "${var.env}-data-subnet" = ["Microsoft.Sql"]
  }
  tags = {
    environment = var.env
  }
}