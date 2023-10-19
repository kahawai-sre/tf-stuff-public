provider "azurerm" {
  alias           = "generic"
  subscription_id = "xxxxxxxxxxxxxxxxxxxxxxx"
  features {}
}

#// Connectivity provider is required for managing the per-supscription VNET=>vWAN Virtual Hub connections in the central connectivity subscription:
provider "azurerm" {
  alias           = "connectivity01"
  subscription_id = "xxxxxxxxxxxxxxxxxxxx"
  features {}
}

terraform {
  backend "azurerm" {
    # resource_group_name = "tf-state"
    # storage_account_name = "saaetf"
    # container_name = "tfstate"
    # key             = "prod.connectivity01.tfstate"
    subscription_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    tenant_id       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }
}
