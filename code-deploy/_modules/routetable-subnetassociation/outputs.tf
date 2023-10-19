output "subnet_id" {
  description = "The id of the subnet newly associated with this NSG"
  value       = azurerm_subnet_route_table_association.this.id
}

