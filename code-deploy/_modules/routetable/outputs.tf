output "routetable_id" {
  description = "The id of the newly created route table"
  value       = azurerm_route_table.this.id
}

output "routetable_subnets" {
  value = azurerm_route_table.this.subnets
}

