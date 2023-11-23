terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~>1.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.44.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.connectivitySubscriptionId
  features {}
}

provider "azurerm" {
  alias           = "corpventure0002"
  subscription_id = var.corpventure0002SubscriptionId
  features {}
}
