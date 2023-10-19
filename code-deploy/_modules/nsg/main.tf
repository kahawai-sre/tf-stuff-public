
resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rule       = var.security_rules
  tags                = var.tags
}


