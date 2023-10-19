output "subnet_id" {
  description = "The id of the subnet newly associated with this NSG"
  value       = azurerm_subnet_network_security_group_association.this.id
}

