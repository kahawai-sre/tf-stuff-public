



resource "azurerm_network_ddos_protection_plan" "this" {
  count               = var.ddos_protection_plan_name == null ? 0 : 1
  name                = var.ddos_protection_plan_name
  location            = var.ddos_protection_plan_location
  resource_group_name = var.ddos_protection_plan_resourcegroup_name
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space // list
  dns_servers         = var.dns_servers   // list
  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_name == null ? range(0) : range(1)
    iterator = v
    content {
      id     = azurerm_network_ddos_protection_plan.this[0].id
      enable = true
    }
  }
  bgp_community = var.bgp_community
  tags          = var.tags // map
}




