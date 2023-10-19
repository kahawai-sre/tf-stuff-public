
locals {
  // IMPORTANT NOTE ON PROCESSING EACH CONFIG FILE (yaml):
  // -----------------------------------------------------
  // 1. => If config file is empty, no instances of that resource will be enumerated. 
  // 2. => If a file with *active deployed* config is then commented out (becomes empty), that results in resources being deleted (caught in PLAN!)
  // 3. => If there is a syntax error with the config, the same applies. All instances of that resource will be deleted (caught in PLAN!)
  // 4. => If var.validate_yaml = true, attempt *native* yaml parsing. Use this to return yaml parsing errors as opposed to nulling those resources. 
  //  4.1 => With 'var.validate_yaml = true' the code will not handle empty or fully commented-out files

  // Resource group config
  rg_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.resourcegroups_yaml))) ? file(var.resourcegroups_yaml) : "[]") : yamldecode(file(var.resourcegroups_yaml))

  // VNET config
  vnet_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.vnets_yaml))) ? file(var.vnets_yaml) : "[]") : yamldecode(file(var.vnets_yaml))

  // Subnet config
  subnet_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.subnets_yaml))) ? file(var.subnets_yaml) : "[]") : yamldecode(file(var.subnets_yaml))

  // vHub connection config
  vhubconn_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.vhubconnections_yaml))) ? file(var.vhubconnections_yaml) : "[]") : yamldecode(file(var.vhubconnections_yaml))

  // VNET peering config
  vnetpeering_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.vnet_peerings_yaml))) ? file(var.vnet_peerings_yaml) : "[]") : yamldecode(file(var.vnet_peerings_yaml))

  // Route table config (includes routes, and subnet associations)
  routetable_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.routetables_yaml))) ? file(var.routetables_yaml) : "[]") : yamldecode(file(var.routetables_yaml))

  // Route table subnet association config
  routetable_subnet_associations_flatten = local.routetable_config != [] ? flatten([for routetable in local.routetable_config :
    [for routetable_subnet_association in routetable.subnet_route_table_associations :
      {
        name            = routetable_subnet_association.name
        routetable_name = routetable.name
        subnet_name     = routetable_subnet_association.subnet_name
      }
    ]
  ]) : []
  routetable_subnet_associations_map = local.routetable_subnet_associations_flatten != [] ? { for routetable_subnet_association in local.routetable_subnet_associations_flatten : routetable_subnet_association.name => routetable_subnet_association } : {}

  // Private DNS Zone config
  pdns_zone_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.pdns_zones_yaml))) ? file(var.pdns_zones_yaml) : "[]") : yamldecode(file(var.pdns_zones_yaml))

  // Private DNS ZOne => VNET links config
  pdns_vnetlink_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.pdns_vnetlink_yaml))) ? file(var.pdns_vnetlink_yaml) : "[]") : yamldecode(file(var.pdns_vnetlink_yaml))

  // ASG config
  asg_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.asgs_yaml))) ? file(var.asgs_yaml) : "[]") : yamldecode(file(var.asgs_yaml))

  // NSG config (includes rules, and NSG-subnet associations)
  nsg_config_raw = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.nsgs_yaml))) ? file(var.nsgs_yaml) : "[]") : yamldecode(file(var.nsgs_yaml))
  nsg_config_flatten = local.nsg_config_raw != [] ? flatten([
    for nsg in local.nsg_config_raw : {
      name                = nsg.name
      resource_group_name = nsg.resource_group_name
      location            = nsg.location // list
      // Concat (combine) rules defined in the specific NSG, with both global default rules (if any), and NSG 'persona' rules
      security_rules = concat(
        [nsg.security_rules, []][try(nsg.security_rules, null) != null ? 0 : 1],
        [lookup(local.nsg_persona_defaultrules_map, nsg.persona, null).default_security_rules, []][nsg.apply_persona_rules == true ? 0 : 1],
        [local.nsg_default_security_rules_raw.default_security_rules, []][nsg.apply_default_rules == true ? 0 : 1]
      )
      subnet_network_security_group_associations = try(nsg.subnet_network_security_group_associations, null)
      tags                                       = try(nsg.tags, null)
    }
  ]) : []
  nsg_config = local.nsg_config_flatten != [] ? { for nsg_config in local.nsg_config_flatten : nsg_config.name => nsg_config } : {}

  // NSG Subnet Associations
  nsg_subnet_associations_flatten = local.nsg_config_raw != [] ? flatten([for nsg in local.nsg_config_raw :
    [for nsg_subnet_association in nsg.subnet_network_security_group_associations :
      {
        name        = nsg_subnet_association.name
        nsg_name    = nsg.name
        subnet_name = nsg_subnet_association.subnet_name
      }
    ]
    if nsg.subnet_network_security_group_associations != null
  ]) : []
  nsg_subnet_associations_map = local.nsg_subnet_associations_flatten != [] ? { for nsg_subnet_association in local.nsg_subnet_associations_flatten : nsg_subnet_association.name => nsg_subnet_association } : {}

  // IP Prefixes config
  ipprefixes_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.ipprefixes_yaml))) ? file(var.ipprefixes_yaml) : "[]") : yamldecode(file(var.ipprefixes_yaml))

  // Public IPs config
  publicips_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.publicips_yaml))) ? file(var.publicips_yaml) : "[]") : yamldecode(file(var.publicips_yaml))

  // IP Groups config
  ipgroups_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.ipgroups_yaml))) ? file(var.ipgroups_yaml) : "[]") : yamldecode(file(var.ipgroups_yaml))

  // AzFw Base Policies config
  azfwbasepolicies_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.azfwbasepolicies_yaml))) ? file(var.azfwbasepolicies_yaml) : "[]") : yamldecode(file(var.azfwbasepolicies_yaml))

  // AzFw Child Policies config
  azfwchildpolicies_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.azfwchildpolicies_yaml))) ? file(var.azfwchildpolicies_yaml) : "[]") : yamldecode(file(var.azfwchildpolicies_yaml))

  // AzFw Rule Collection Groups config
  azfwrulecollgroups_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.azfwrulecollgroups_yaml))) ? file(var.azfwrulecollgroups_yaml) : "[]") : yamldecode(file(var.azfwrulecollgroups_yaml))

}


