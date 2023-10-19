resource "azurerm_virtual_hub_connection" "this" {
  name                      = var.name
  virtual_hub_id            = var.virtual_hub_id
  remote_virtual_network_id = var.remote_virtual_network_id
  internet_security_enabled = var.internet_security_enabled
  dynamic "routing" {
    for_each = var.routing != null ? var.routing : []
    content {
      associated_route_table_id = routing.value.associated_route_table
      dynamic "propagated_route_table" {
        for_each = routing.value.propagated_route_table == null ? [] : routing.value.propagated_route_table
        content {
          route_table_ids = try(propagated_route_table.value.route_table_ids, null) #// List
          labels          = try(propagated_route_table.value.labels, null)
        }
      }
      dynamic "static_vnet_route" {
        for_each = routing.value.static_vnet_route == null ? [] : routing.value.static_vnet_route
        content {
          name                = try(static_vnet_route.value.name, null)
          address_prefixes    = try(static_vnet_route.value.address_prefixes, null) #// List
          next_hop_ip_address = try(static_vnet_route.value.next_hop_ip_address, null)
        }
      }
    }
  }
}

#// Will need AZAPI to configure the following if needed:
#// ======================================================
#// Bypass Next Hop IP for workloads within this VNet: StaticRoutesConfig => vnetLocalRouteOverrideCriteria
#// Propagate static route (not documented for ARM or terraform yet, being rolled out): REST API: StaticRoutesConfig => propagateStaticRoutes
#// NOTE: ALL static routing configuration options are DISABLED when Routing Intent is enabled on the vHub, so it has significant pros and cons (!!!!!)
#// e.g. only way to inject routes into hub or otherwise bypass vHub routing via Azure Firewall is via either:
#// (a) Disabling entwork policies on subnets with Private Endpoints;
#// (b) BGP peering NVA in spoke with vHub peering endpoint (requires support for ebgp);
#// (c) Direct VNET peering/mesh
# See https://learn.microsoft.com/en-us/rest/api/virtualwan/hub-virtual-network-connections/create-or-update?tabs=HTTP#staticroutesconfig
# Also see https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-virtual-hub-routing#routing-configuration

