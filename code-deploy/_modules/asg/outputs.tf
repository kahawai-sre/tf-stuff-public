output "asg_id" {
  description = "The id of the newly created asg"
  value       = azurerm_application_security_group.this.id
}

