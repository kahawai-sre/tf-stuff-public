
variable "name" {
}

variable "resource_group_name" {
}

variable "location" {
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "security_rules" {
  type = list(object({
    name                                       = string
    access                                     = string
    direction                                  = string
    priority                                   = number
    protocol                                   = string
    description                                = optional(string, "")
    source_address_prefix                      = optional(string, "")
    source_address_prefixes                    = optional(list(string), [])
    source_application_security_group_ids      = optional(list(string), [])
    source_port_range                          = optional(string, "")
    source_port_ranges                         = optional(list(string), [])
    destination_address_prefix                 = optional(string, "")
    destination_address_prefixes               = optional(list(string), [])
    destination_application_security_group_ids = optional(list(string), [])
    destination_port_range                     = optional(string, "")
    destination_port_ranges                    = optional(list(string), [])
  }))
}


