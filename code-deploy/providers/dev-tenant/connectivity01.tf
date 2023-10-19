provider "azurerm" {
  alias           = "generic"
  subscription_id = "xxxxxxxxxxxxxxxxxxxxxxx"
  features {}
}

#// Connectivity provider is required for managing the per-supscription VNET=>vWAN Virtual Hub connections in the central connectivity subscription:
provider "azurerm" {
  alias           = "connectivity01"
  subscription_id = "xxxxxxxxxxxxxxxxxxxxx"
  features {}
}

terraform {
  backend "azurerm" {
    # resource_group_name = "tf-state"
    # storage_account_name = "saaetf"
    # container_name = "tfstate"
    # key = "dev.connectivity01.tfstate"
    subscription_id = "xxxxxxxxxxxxxxxxx"
    tenant_id       = "xxxxxxxxxxxxxxxxx"
  }
}


#// ----- CONNECTIVITY-SPECIFIC CONFIG ---------
# PDNSZONE-VNET links yaml and configuration:
# variable "pdns_vnetlink_yaml" {
#   default = "../config-corenetworking/dev-tenant/connectivity/connectivity01/pdnszone-vnetlinks.yaml"
# }

# locals {
#   # PDNS VNET link config
#   pdns_vnetlink_config = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.pdns_vnetlink_yaml))) ? file(var.pdns_vnetlink_yaml) : "[]") : yamldecode(file(var.pdns_vnetlink_yaml))
# }






