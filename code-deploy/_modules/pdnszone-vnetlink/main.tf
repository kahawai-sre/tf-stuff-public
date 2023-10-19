

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                    = var.name
  resource_group_name     = var.resource_group_name #RG where Private DNS zone exists
  private_dns_zone_name   = var.private_dns_zone_name
  virtual_network_id      = var.virtual_network_id
  registration_enabled    = var.registration_enabled
  tags                    = var.tags #map
}
