
#// ------------ CORE NETWORKING --------------

// Resource Groups
module "resourcegroup" {
  for_each = {
    for index, rg in local.rg_config :
    rg.name => rg
  }
  providers = {
    azurerm = azurerm.generic
  }
  source   = "./_modules/resourcegroup/"
  name     = each.value.resource_name
  location = each.value.location
  tags     = try(each.value.tags, null)
}

// vNets
module "vnet" {
  depends_on = [
    module.resourcegroup
  ]
  for_each = {
    for index, vnet in local.vnet_config :
    vnet.name => vnet
  }
  providers = {
    azurerm = azurerm.generic
  }
  source                                  = "./_modules/vnet/"
  name                                    = each.value.resource_name
  location                                = each.value.location
  resource_group_name                     = each.value.resource_group_name
  address_space                           = try(each.value.address_space, null)
  dns_servers                             = try(each.value.dns_servers, null)
  ddos_protection_plan_name               = try(each.value.ddos_protection_plan_name, null)
  ddos_protection_plan_location           = try(each.value.ddos_protection_plan_location, null)
  ddos_protection_plan_resourcegroup_name = try(each.value.ddos_protection_plan_resourcegroup_name, null)
  bgp_community                           = try(each.value.bgp_community, null)
  tags                                    = try(each.value.tags, null)
}

// Subnets
module "subnets" {
  depends_on = [
    module.vnet
  ]
  for_each = {
    for index, subnet in local.subnet_config :
    subnet.name => subnet
  }
  providers = {
    azurerm = azurerm.generic
  }
  source                                        = "./_modules/subnet/"
  name                                          = each.value.name
  virtual_network_name                          = each.value.virtual_network_name
  resource_group_name                           = each.value.resource_group_name
  address_prefixes                              = try(each.value.address_prefixes, null)
  service_endpoints                             = try(each.value.service_endpoints, null)
  service_endpoint_policy_ids                   = try(each.value.service_endpoint_policy_ids, null)
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  delegation                                    = try(each.value.service_delegations, null)
}

// vNET => vWAN Virtual Hub Connections:
module "virtualhubconnection" {
  providers = {
    azurerm = azurerm.connectivity01
  }
  for_each = {
    for index, vhubconn in local.vhubconn_config :
    vhubconn.name => vhubconn
  }
  source = "./_modules/virtualhubconnection/"
  name   = each.value.name
  #virtual_hub_id                  = module.virtualhub[each.value.virtual_hub_name].virtualhub_id
  virtual_hub_id                        = each.value.virtual_hub_id
  remote_virtual_network_id             = module.vnet[each.value.remote_virtual_network_name].vnet_id
  internet_security_enabled             = try(each.value.internet_security_enabled, null)
  hub_to_vitual_network_traffic_allowed = try(each.value.hub_to_vitual_network_traffic_allowed, null)
  routing = try(each.value.routing, null) == null ? null : [for routesetting in each.value.routing :
    {
      associated_route_table = try(routesetting.associated_route_table, null)
      propagated_route_table = try(routesetting.propagated_route_table == null ? null : [for prt in routesetting.propagated_route_table :
        {
          route_table_ids = prt.route_table_ids
          labels          = prt.labels
      }], null)
      static_vnet_route = try(routesetting.static_vnet_route == null ? null : [for staticroute in routesetting.static_vnet_route :
        {
          name                = staticroute.name
          address_prefixes    = staticroute.address_prefixes
          next_hop_ip_address = staticroute.next_hop_ip_address
      }], null)
  }]
}

// VNET Peerings
module "vnetpeering" {
  depends_on = [
    module.virtualhubconnection
  ]
  for_each = {
    for index, peering in local.vnetpeering_config :
    peering.name => peering
  }

  providers = {
    azurerm = azurerm.generic
  }
  source                       = "./_modules/vnetpeering"
  name                         = each.value.name
  resource_group_name          = each.value.resource_group_name
  virtual_network_name         = module.vnet[each.value.local_virtual_network_name].vnet_name
  remote_virtual_network_id    = module.vnet[each.value.remote_virtual_network_name].vnet_id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}

module "routetable" {
  for_each = {
    for index, rt in local.routetable_config :
    rt.name => rt
  }
  providers = {
    azurerm = azurerm.generic
  }
  source                        = "./_modules/routetable/"
  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  disable_bgp_route_propagation = try(each.value.disable_bgp_route_propagation, null)
  routes = try(each.value.routes, null) == null ? null : { for x in [for route in each.value.routes :
    {
      name                   = route.name
      address_prefix         = route.address_prefix
      next_hop_type          = route.next_hop_type
      next_hop_in_ip_address = try(route.next_hop_in_ip_address, null)
    }
  ] : x.name => x }
  tags = try(each.value.tags, null)
}

module "routetable-subnetassociation" {
  for_each = local.routetable_subnet_associations_map
  providers = {
    azurerm = azurerm.generic
  }
  source         = "./_modules/routetable-subnetassociation"
  route_table_id = module.routetable[each.value.routetable_name].routetable_id
  subnet_id      = module.subnets[each.value.subnet_name].subnet_id
}

module "dnsprivatezones-connectivity" {
  depends_on = [
    module.resourcegroup
  ]
  providers = {
    azurerm = azurerm.connectivity01
  }
  for_each = {
    for index, pdnszone in local.pdns_zone_config :
    pdnszone.name => pdnszone
  }
  #for_each = local.connectivity_dnsprivatezones_config_map  == null ? {} : local.connectivity_dnsprivatezones_config_map
  source              = "./_modules/pdnszone/"
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  soa_record          = each.value.soa_record
  tags                = try(each.value.tags, null)
}

module "pdnszone-vnetlink-connectivity" {
  depends_on = [
    module.vnet
  ]
  for_each = {
    for index, pdnslink in local.pdns_vnetlink_config :
    pdnslink.name => pdnslink
  }
  providers = {
    azurerm = azurerm.connectivity01
  }
  source                = "./_modules/pdnszone-vnetlink/"
  name                  = each.value.name
  resource_group_name   = each.value.resource_group_name   # RG holding the PDNS zone instance to link
  private_dns_zone_name = each.value.private_dns_zone_name # Name of PDNS zone to link
  virtual_network_id    = module.vnet[each.value.virtual_network_name].vnet_id
  registration_enabled  = each.value.registration_enabled # A-record registration enabled (for VMs, single VNET link per PDNS zone instance only)
  tags                  = try(each.value.tags, null)
}

# #// ------------ NETWORK PROTECTION --------------

// ASGs
module "asgs" {
  providers = {
    azurerm = azurerm.generic
  }
  depends_on = [
    module.resourcegroup
  ]
  for_each = {
    for index, asg in local.asg_config :
    asg.name => asg
  }
  source              = "./_modules/asg/"
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = try(each.value.tags, null)
}

// NSGs
module "nsgs" {
  depends_on = [
    module.asgs
  ]
  providers = {
    azurerm = azurerm.generic
  }
  for_each            = local.nsg_config
  source              = "./_modules/nsg/"
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags
  security_rules = each.value.security_rules == null ? null : [for rule in each.value.security_rules :
    {
      name                                       = rule.name
      access                                     = rule.access
      direction                                  = rule.direction
      priority                                   = rule.priority
      protocol                                   = rule.protocol
      description                                = try(rule.description, "")
      source_address_prefix                      = try(rule.source_address_prefix, "")
      source_address_prefixes                    = try(rule.source_address_prefixes, [])
      source_port_range                          = try(rule.source_port_range, "")
      source_port_ranges                         = try(rule.source_port_ranges, [])
      destination_address_prefix                 = try(rule.destination_address_prefix, "")
      destination_address_prefixes               = try(rule.destination_address_prefixes, [])
      destination_port_range                     = try(rule.destination_port_range, "")
      destination_port_ranges                    = try(rule.destination_port_ranges, [])
      source_application_security_group_ids      = try([for SASGs in rule.source_application_security_group_names : module.asgs[SASGs].asg_id], [])
      destination_application_security_group_ids = try([for DASGs in rule.destination_application_security_group_names : module.asgs[DASGs].asg_id], [])
    }
  ]
}

// NSG Subnet Associations
module "nsg-subnetassociations" {
  depends_on = [
    module.nsgs, module.subnets
  ]
  providers = {
    azurerm = azurerm.generic
  }
  for_each                  = local.nsg_subnet_associations_map
  source                    = "./_modules/nsg-subnetassociation"
  network_security_group_id = module.nsgs[each.value.nsg_name].nsg_id
  subnet_id                 = module.subnets[each.value.subnet_name].subnet_id
}

# // IP Prefixes for FW policy

# module "ipprefixes" {
#   depends_on = [
#     module.resourcegroup
#   ]
#   providers = {
#     azurerm = azurerm.generic
#   }
#   for_each = {
#     for index, ipprefix in local.ipprefixes_config :
#     ipprefix.name => ipprefix
#   }
#   #var.ddos_protection_plan_name == null ? range(0) : range(1)
#   source              = "./_modules/ipprefix"
#   name                = each.value.name
#   resource_group_name = each.value.resource_group_name
#   location            = each.value.location
#   prefix_length       = each.value.prefix_length
#   sku                 = try(each.value.sku, null)
#   zones               = try(each.value.zones, null) # Zone Redundant for standard SKU by default
#   tags                = try(each.value.tags, null)  #map
# }

# // Public IPs based on prefixes, for FW Policy
# module "publicips" {
#   depends_on = [
#     module.ipprefixes
#   ]
#   providers = {
#     azurerm = azurerm.generic
#   }
#   for_each = {
#     for index, publicip in local.publicips_config :
#     publicip.name => publicip
#   }
#   source                  = "./_modules/publicip"
#   name                    = each.value.name
#   resource_group_name     = each.value.resource_group_name
#   location                = each.value.location
#   allocation_method       = each.value.allocation_method
#   sku                     = try(each.value.sku, null)
#   ip_version              = try(each.value.ip_version, null)
#   idle_timeout_in_minutes = try(each.value.idle_timeout_in_minutes, null)
#   domain_name_label       = try(each.value.domain_name_label, null)
#   reverse_fqdn            = try(each.value.reverse_fqdn, null)
#   public_ip_prefix_id     = try(module.ipprefixes[each.value.public_ip_prefix_name].id, null)
#   zones                   = try(each.value.zones, null) # Zone Redundant for standard SKU by default
#   tags                    = try(each.value.tags, null)  #map
# }

# // IP groups, for FW policy
# module "ipgroups" {
#   depends_on = [
#     module.resourcegroup
#   ]
#   providers = {
#     azurerm = azurerm.generic
#   }
#   for_each = {
#     for index, ipgroup in local.ipgroups_config :
#     ipgroup.name => ipgroup
#   }
#   source              = "./_modules/ipgroup"
#   name                = each.value.name
#   resource_group_name = each.value.resource_group_name
#   location            = each.value.location
#   cidrs               = each.value.cidrs
#   tags                = each.value.tags #map
# }

# module "azurefirewallbasepolicy" {
#   depends_on = [
#     module.resourcegroup, module.publicips, module.ipgroups
#   ]
#   providers = {
#     azurerm = azurerm.generic
#   }
#   for_each = {
#     for index, fwpol in local.azfwbasepolicies_config :
#     fwpol.name => fwpol
#   }
#   source                        = "./_modules/azurefirewallpolicy"
#   name                          = each.value.name
#   resource_group_name           = each.value.resource_group_name
#   location                      = each.value.location
#   sku                           = each.value.sku
#   intrusion_detection           = try(each.value.intrusion_detection, null)
#   threat_intelligence_mode      = try(each.value.threat_intelligence_mode, null)
#   threat_intelligence_allowlist = try(each.value.threat_intelligence_allowlist, null)
#   dns                           = try(each.value.dns, null)
#   identity                      = try(each.value.identity, null)
#   tls_certificate               = try(each.value.tls_certificate, null)
#   explicit_proxy                = try(each.value.explicit_proxy, null)
#   insights                      = try(each.value.insights, null)
#   tags                          = try(each.value.tags, null)
# }

# module "azurefirewallchildpolicy" {
#   depends_on = [
#     module.resourcegroup, module.publicips, module.ipgroups
#   ]
#   providers = {
#     azurerm = azurerm.generic
#   }
#   for_each = {
#     for index, fwpol in local.azfwchildpolicies_config :
#     fwpol.name => fwpol
#   }
#   source                        = "./_modules/azurefirewallpolicy"
#   name                          = each.value.name
#   resource_group_name           = each.value.resource_group_name
#   location                      = each.value.location
#   sku                           = each.value.sku
#   base_policy_id                = module.azurefirewallbasepolicy[each.value.base_policy_name].firewallpolicy_id
#   intrusion_detection           = try(each.value.intrusion_detection, null)
#   threat_intelligence_mode      = try(each.value.threat_intelligence_mode, null)
#   threat_intelligence_allowlist = try(each.value.threat_intelligence_allowlist, null)
#   dns                           = try(each.value.dns, null)
#   identity                      = try(each.value.identity, null)
#   tls_certificate               = try(each.value.tls_certificate, null)
#   explicit_proxy                = try(each.value.explicit_proxy, null)
#   insights                      = try(each.value.insights, null)
#   tags                          = try(each.value.tags, null)
# }

# module "azurefirewallpolicyrulecollectiongroup" {
#   providers = {
#     azurerm = azurerm.generic
#   }
#   depends_on = [
#     module.resourcegroup, module.azurefirewallbasepolicy, module.azurefirewallchildpolicy
#   ]
#   for_each = {
#     for index, fwrulecoll in local.azfwrulecollgroups_config :
#     fwrulecoll.name => fwrulecoll
#   }
#   source             = "./_modules/azurefirewallpolicyrulecollectiongroup"
#   name               = each.value.name
#   priority           = each.value.priority
#   firewall_policy_id = module.azurefirewallchildpolicy[each.value.fw_policy_name].firewallpolicy_id
#   application_rule_collection = each.value.application_rule_collections == null ? null : [for application_rule_collection in each.value.application_rule_collections :
#     {
#       name     = application_rule_collection.name,
#       action   = application_rule_collection.action,
#       priority = application_rule_collection.priority,
#       rule = [for rule in application_rule_collection.rules :
#         {
#           name                  = rule.name,
#           source_addresses      = try(rule.source_addresses, []),
#           source_ip_groups      = lookup(rule, "source_ip_groups", null) == null ? [] : [for ipgroupname in rule.source_ip_groups : module.ipgroups[ipgroupname].ipgroup_id],
#           destination_fqdns     = try(rule.destination_fqdns, []),
#           destination_fqdn_tags = try(rule.destination_fqdn_tags, []),
#           protocols             = rule.protocols
#         }
#       ]
#   }]
#   network_rule_collection = each.value.network_rule_collections == null ? null : [for network_rule_collection in each.value.network_rule_collections :
#     {
#       name     = network_rule_collection.name,
#       action   = network_rule_collection.action,
#       priority = network_rule_collection.priority,
#       rule = [for rule in network_rule_collection.rules :
#         {
#           name                  = rule.name,
#           source_addresses      = try(rule.source_addresses, []),
#           source_ip_groups      = lookup(rule, "source_ip_groups", null) == null ? [] : [for ipgroupname in rule.source_ip_groups : module.ipgroups[ipgroupname].ipgroup_id],
#           destination_addresses = try(rule.destination_addresses, []),
#           destination_ip_groups = lookup(rule, "destination_ip_groups", null) == null ? [] : [for ipgroupname in rule.destination_ip_groups : module.ipgroups[ipgroupname].ipgroup_id],
#           destination_fqdns     = try(rule.destination_fqdns, []),
#           destination_ports     = try(rule.destination_ports, []),
#           protocols             = rule.protocols
#         }
#       ]
#   }]
#   nat_rule_collection = each.value.nat_rule_collections == null ? null : [for nat_rule_collection in each.value.nat_rule_collections :
#     {
#       name     = nat_rule_collection.name,
#       action   = nat_rule_collection.action,
#       priority = nat_rule_collection.priority,
#       rule = [for rule in nat_rule_collection.rules :
#         {
#           name                = rule.name,
#           source_ip_groups    = lookup(rule, "source_ip_groups", null) == null ? [] : [for ipgroupname in rule.source_ip_groups : module.ipgroups[ipgroupname].ipgroup_id],
#           destination_address = lookup(rule, "destination_address_public_ip_name", null) == null ? "" : module.publicips[rule.destination_address_public_ip_name].publicip_ip,
#           destination_ports   = try(rule.destination_ports, []),
#           source_addresses    = try(rule.source_addresses, []),
#           protocols           = rule.protocols
#           translated_address  = try(rule.translated_address, ""),
#           translated_port     = try(rule.translated_port, "")
#         }
#       ]
#   }]
# }
