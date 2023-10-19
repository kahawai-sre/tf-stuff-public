
variable "name" {
}

variable "resource_group_name" {
}

variable "location" {
}

variable "disable_bgp_route_propagation" {
  default = false
}

# variable "routes" {
#   type    = any
#   default = null
# }

# variable "routes" {
#   type = list(object({
#     name                   = string
#     address_prefix         = string                 #// Destination to which route applies. Either CIDR or Azure Service Tag e.g. "AzureMonitor", "AzureBackup", "ApiManagement"
#     next_hop_type          = string                 #// VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, None
#     next_hop_in_ip_address = optional(string, null) #// Next IP address, only valid when next_hop_type = "VirtualAppliance"
#   }))
# }

#// Using discrete azurerm_route resource
variable "routes" {
  type = map(object({
    name                   = string
    address_prefix         = string                 #// Destination to which route applies. Either CIDR or Azure Service Tag e.g. "AzureMonitor", "AzureBackup", "ApiManagement"
    next_hop_type          = string                 #// VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, None
    next_hop_in_ip_address = optional(string, null) #// Next IP address, only valid when next_hop_type = "VirtualAppliance"
  }))
}

variable "tags" {
  type    = map(string)
  default = null
}
