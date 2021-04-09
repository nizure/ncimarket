# resource "azurerm_public_ip" "pip" {
#   name                = "publicIp1"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   tags                = var.tags
# }

# resource "azurerm_application_gateway" "network" {
#   name                = var.apgw_name
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   sku {
#     name     = var.app_gateway_sku
#     tier     = var.app_gateway_sku
#     capacity = 1
#   }

#   gateway_ip_configuration {
#     name      = "appGatewayIpConfig"
#     subnet_id = module.vnet.vnet_subnets[1]
#   }

#   frontend_port {
#     name = "${var.apgw_name}-feport"
#     port = 80
#   }

#   frontend_port {
#     name = "httpsPort"
#     port = 443
#   }

#   frontend_ip_configuration {
#     name                 = "${var.apgw_name}-feip"
#     public_ip_address_id = azurerm_public_ip.pip.id
#   }

#   backend_address_pool {
#     name = "${var.apgw_name}-beap"
#   }

#   backend_http_settings {
#     name                  = "${var.apgw_name}-be-htst"
#     cookie_based_affinity = "Disabled"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 1
#   }

#   http_listener {
#     name                           = "${var.apgw_name}-httplstn"
#     frontend_ip_configuration_name = "${var.apgw_name}-feip"
#     frontend_port_name             = "${var.apgw_name}-feport"
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = "${var.apgw_name}-rqrt"
#     rule_type                  = "Basic"
#     http_listener_name         = "${var.apgw_name}-httplstn"
#     backend_address_pool_name  = "${var.apgw_name}-beap"
#     backend_http_settings_name = "${var.apgw_name}-be-htst"
#   }

#   tags = var.tags

#   depends_on = [module.vnet, azurerm_public_ip.pip]
# }