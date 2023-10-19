output "publicip_id" {
  value       = azurerm_public_ip.this.id
}

output "publicip_ip" {
  value       = azurerm_public_ip.this.ip_address
}
