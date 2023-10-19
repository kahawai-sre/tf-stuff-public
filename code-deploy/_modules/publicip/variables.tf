variable "name" {
}

variable "resource_group_name" {
}

variable "location" {
}

variable "allocation_method" {
}


variable "sku" {
}


variable "sku_tier" {
  default = null
}


variable "ip_version" {
  default = null
}

variable "idle_timeout_in_minutes" {
  default = null
}

variable "domain_name_label" {
  default = null
}

variable "reverse_fqdn" {
  default = null
}

variable "public_ip_prefix_id" {
  default = null
}

variable "zones" {
  default = null
}

variable "tags" {
  type    = map(string)
  default = null
}

