

#// ------------ CORE NETWORKING --------------

#// Resource Groups config file path 
variable "resourcegroups_yaml" {
  #default = "../../../config-corenetworking/dev-tenant/corp/corp01/resource-groups.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.resourcegroups_yaml)),
      can(yamldecode(file(var.resourcegroups_yaml))),
      can(file(var.resourcegroups_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.resourcegroups_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}

#// VNETs config file path 
variable "vnets_yaml" {
  #default = "../../../config-corenetworking/dev-tenant/corp/corp01/vnets.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.vnets_yaml)),
      can(file(var.vnets_yaml)),
      #can(yamldecode(file(var.vnets_yaml)))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.vnets_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}

#// Subnets config file path 
variable "subnets_yaml" {
  #default = "../../../config-corenetworking/dev-tenant/corp/corp01/subnets.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.subnets_yaml)),
      can(file(var.subnets_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.subnets_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}

#// vHub VNET peerings config file path 
variable "vnet_peerings_yaml" {
  #default = "../../../config-corenetworking/dev-tenant/corp/corp01/vnet-peerings.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.vnet_peerings_yaml)),
      can(file(var.vnet_peerings_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.vnet_peerings_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}

#// vHub VNET connections config file path 
variable "vhubconnections_yaml" {
  #default = "../../../config-corenetworking/dev-tenant/corp/corp01/vhub-connections.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.vhubconnections_yaml)),
      can(file(var.vhubconnections_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.vhubconnections_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}

#// Route tables 
variable "routetables_yaml" {
  #default = "../../../config-corenetworking/dev-tenant/corp/corp01/routetables.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.routetables_yaml)),
      can(file(var.routetables_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.routetables_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}



#// Private DNS Zones
variable "pdns_zones_yaml" {
  #default = "../../../config-corenetworking/dev-tenant/corp/corp01/pdnszone.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.pdns_zones_yaml)),
      can(file(var.pdns_zones_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.pdns_zones_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}


#// Private DNS Zone => VNET links
variable "pdns_vnetlink_yaml" {
  #default = "../../../config-corenetworking/dev-tenant/corp/corp01/pdnszone-vnetlinks.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.pdns_vnetlink_yaml)),
      can(file(var.pdns_vnetlink_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.pdns_vnetlink_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}


#// ------------ NETWORK PROTECTION --------------

#// ASGs config file path 
variable "asgs_yaml" {
  #default = "../../../config-networkprotection/dev-tenant/corp/corp01/asgs.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.asgs_yaml)),
      can(file(var.asgs_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.asgs_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}

#// NSGs config file path 
variable "nsgs_yaml" {
  #default = "../../../config-networkprotection/dev-tenant/corp/corp01/nsgs.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.nsgs_yaml)),
      can(file(var.nsgs_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.nsgs_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}

variable "ipgroups_yaml" {
  default = null
}
variable "ipprefixes_yaml" {
  default = null
}

variable "publicips_yaml" {
  default = null
}

variable "azfwbasepolicies_yaml" {
  default = null
}

variable "azfwchildpolicies_yaml" {
  default = null
}

variable "azfwrulecollgroups_yaml" {
  default = null
}


