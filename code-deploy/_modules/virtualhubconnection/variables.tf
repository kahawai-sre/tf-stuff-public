variable "name" {
}

variable "virtual_hub_id" {
}

variable "remote_virtual_network_id" {
}

variable "internet_security_enabled" {
}

variable "hub_to_vitual_network_traffic_allowed" {
}

variable "routing" {
  type    = any
  default = null
}
