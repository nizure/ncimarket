variable "env" {
  type        = string
  description = "Environment Name"
  default     = "dev01"
#   default     = "prod"
}
variable "location" {
  type    = string
  default = "eastus"
#   default = "westeurope"
}

variable "vnet_address_prefix" {
  description = "VNET address prefix"
  default     = "10.100.0.0/18"
}

variable "aks_subnet_address_prefix" {
  description = "Subnet address prefix."
  default     = "10.100.0.0/20"
}

variable "gateway_subnet_address_prefix" {
  description = "gateway subnet address prefix."
  default     = "10.100.16.0/25"
}

variable "admin_subnet_address_prefix" {
  description = "gateway subnet address prefix."
  default     = "10.100.17.0/24"
}
