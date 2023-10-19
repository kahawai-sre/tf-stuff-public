resource "azurerm_virtual_hub" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  virtual_wan_id          = var.virtual_wan_id
  address_prefix          = var.address_prefix
}