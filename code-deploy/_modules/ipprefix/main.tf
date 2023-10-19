

resource "azurerm_public_ip_prefix" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku                     = var.sku
  prefix_length           = var.prefix_length
  zones       = var.zones # Zone Redundant for standard SKU by default
  tags                    = var.tags #map
}


/*
- name: "pip-vpn-gateway-sharedservices-1"
  resource_name: "pip-vpn-gateway-sharedservices-1"
  location: "australiaeast"
  resource_group_name: "rg-vnet-sharedservices-hub"
  allocation_method: "Static" # Static or Dynamic
  sku: "Standard" # Standard or Basic
  # ip_verion:
  # idle_timeout_in_seconds:
  # domain_name_label:
  # reverse_fqdn:
  # public_ip_prefix_name: # maps to public_ip_prefix_id
  # zones: # Not specifying this, where Standard SKU is set, are deployed as Zone Redundant (by default)
  # tags:
    # cost_center: "1234"
    # environment: "prod"
    # arc_rating: "tier0"
*/


