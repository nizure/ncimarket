variable "env" {
  type        = string
  description = "Environment Name"
#   default     = "prod"
}
variable "location" {
  type    = string
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

variable "aks_subnet_address_prefix" {
  description = "Subnet address prefix."
  default     = "10.100.0.0/20"
}