
resource "azurerm_route_table" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  #route                         = var.routes
  # dynamic "route" {
  #   for_each = var.routes == null ? [] : var.routes
  #   content {
  #     name = route.value.name
  #     address_prefix = route.value.address_prefix
  #     next_hop_type = route.value.next_hop_type
  #     next_hop_in_ip_address = try(route.value.next_hop_in_ip_address, null)
  #   }
  # }
  tags = var.tags
}

#// Using discrete azurerm_route resource due to limitation with inline azurerm_route_table "route":
#// For routes that do not have the optional "next_hop_in_ip_address" property set, it cannot be set to an empty string, but where it is not,
#// for any route where the optional property does not exist, route deletion or change to any route in the list triggers a compare
#// of "" (as the property is stored in state), to a value of null being passed or where the property is not defined, detects a change and redeploys the associated routes.
resource "azurerm_route" "this" {
  for_each               = var.routes == null ? {} : var.routes
  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}
