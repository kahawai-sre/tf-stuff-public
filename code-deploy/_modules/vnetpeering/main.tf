


resource "azurerm_virtual_network_peering" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.virtual_network_name
  remote_virtual_network_id    = var.remote_virtual_network_id
  allow_virtual_network_access = var.allow_virtual_network_access # Allow Virtual Network Access = true is the default, but is not 100% required if you are not relying on the “VirtualNetwork” service tag in NSG. It just turns that off so more specific (IP  IP) rules are required.
  allow_forwarded_traffic      = var.allow_forwarded_traffic      # Default = False. Allows inbound traffic through the peering which has been forwarded by an NVA in another VNET (usually an NVA in the 'hub' vnet). Required for peerings to hub that uses an NVA as default route.
  allow_gateway_transit        = var.allow_gateway_transit        # Allows traffic from the remote vnet to flow over the peering through a virtual network gateway (VPN/Express Route) in the 'local' vnet (usually a gateway in the 'hub' vnet). Set to true for hub-to-spoke peerings, and false for global or hub-hub peerings. Transit can still run through NVA or AzFw.
  use_remote_gateways          = var.use_remote_gateways          # Default = False. Directs traffic inbound to hub to go direct to the gateway as the next hop, potentially bypassing other routes. Set to False on peerings where the intent is for all inbound flows to go via NVA or Azure Firewall. Cannot be set if the vnet has a gateway itself. For full use of gateway from spoke => hub, hub side should enable 'allow gateway transit', and spoke side should enable 'use remote gateways'.
}

