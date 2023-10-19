variable "name" {
}

variable "resource_group_name" {
}

variable "virtual_network_name" {
}

variable "remote_virtual_network_id" {
}

variable "allow_virtual_network_access" {
  type = bool
  default = null
}

variable "allow_forwarded_traffic" {
  type = bool
  default = null
}

variable "allow_gateway_transit" {
  type = bool
  default = null
}

variable "use_remote_gateways" {
  type = bool
  default = null
}

