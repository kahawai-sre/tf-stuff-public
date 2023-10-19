variable "name" {
}

variable "resource_group_name" {
}

variable "location" {
}

variable "address_space" {
  type = list(string)
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  type = list(string)
  default     = null
}

variable "ddos_protection_plan_name" {
    description = "If DDoS standard is to be enabled, this should be populated with the associated DDoS protection plan name mapping to the plan resource ID"
    default = null
}

variable "ddos_protection_plan_location" {
    description = "If DDoS standard is to be enabled, this should be poplated with the associated DDoS protection plan name location"
    default = null
}

variable "ddos_protection_plan_resourcegroup_name" {
    description = "If DDoS standard is to be enabled, this should be poplated with the associated DDoS protection plan resource group"
    default = null
}

variable "bgp_community" {
  description = "The BGP community attribute in format <as-number>:<community-value>"
  default = null
}

variable "tags" {
  type        = map(string)
  default = null
}