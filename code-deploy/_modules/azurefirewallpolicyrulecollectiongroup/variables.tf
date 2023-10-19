
variable "name" {
}

variable "firewall_policy_id" {
}

variable "priority" {
}

variable "application_rule_collection" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    rule = list(object({
      name                  = string
      description           = optional(string, "")
      source_addresses      = optional(list(string), [])
      source_ip_groups      = optional(list(string), [])
      destination_fqdns     = optional(list(string), [])
      destination_fqdn_tags = optional(list(string), [])
      terminate_tls         = optional(bool, false)
      destination_urls      = optional(list(string), [])
      web_categories        = optional(list(string), [])
      protocols = list(object({
        type = string
        port = string
      }))
    }))
  }))
}

variable "network_rule_collection" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    rule = list(object({
      name                  = string
      protocols             = optional(list(string), [])
      source_addresses      = optional(list(string), [])
      source_ip_groups      = optional(list(string), [])
      destination_addresses = optional(list(string), [])
      destination_ip_groups = optional(list(string), [])
      destination_ports     = list(string)
      destination_fqdns     = optional(list(string), [])
    }))
  }))
}

variable "nat_rule_collection" {
  type = list(object({
    name     = string
    priority = number
    action   = string
    rule = list(object({
      name                = string
      protocols           = optional(list(string), [])
      source_addresses    = optional(list(string), [])
      source_ip_groups    = optional(list(string), [])
      destination_address = optional(string, "")
      destination_ports   = optional(list(string), [])
      translated_address  = optional(string, "")
      translated_fqdn     = optional(string, "")
      translated_port     = string
    }))
  }))
}




