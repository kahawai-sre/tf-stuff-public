output "ddospp_id" {
  description = "The id of the newly created DDOS PP"
  value       = azurerm_network_ddos_protection_plan.this.id
}

output "ddospp_name" {
  description = "The Name of the newly created DDOS PP"
  value       = azurerm_network_ddos_protection_plan.this.name
}


