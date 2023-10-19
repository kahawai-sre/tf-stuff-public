output "subnet_id" {
  description = "The id of the newly created vNet"
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  description = "The Name of the newly created vNet"
  value       = azurerm_subnet.this.name
}

output "subnet_vnet_name" {
  description = "The location of the newly created vNet"
  value       = azurerm_subnet.this.virtual_network_name
}

output "subnet_address_prefixes" {
  description = "The address space of the newly created vNet"
  value       = azurerm_subnet.this.address_prefixes
}
