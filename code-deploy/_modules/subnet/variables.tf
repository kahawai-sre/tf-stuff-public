
variable "name" {
}

variable "resource_group_name" {
}

variable "virtual_network_name" {
}

variable "address_prefixes" {
  type = list(string)
}

variable "network_security_group_id" {
  type    = string
  default = null
}

variable "service_endpoints" {
  type    = list(string)
  default = null
}

variable "service_endpoint_policy_ids" {
  type    = list(string)
  default = null
}

variable "enforce_private_link_endpoint_network_policies" {
  type    = bool
  default = null
}

variable "private_endpoint_network_policies_enabled" {
  type    = bool
  default = null
}

variable "private_link_service_network_policies_enabled" {
  type    = bool
  default = null
}

variable "enforce_private_link_service_network_policies" {
  type    = bool
  default = null
}

variable "delegation" {
  type    = any
  default = null
}

