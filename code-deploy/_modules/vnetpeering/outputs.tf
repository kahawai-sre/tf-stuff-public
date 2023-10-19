output "peering_id" {
  description = "The id of the new vnet peering"
  value       = azurerm_virtual_network_peering.this.id
}

