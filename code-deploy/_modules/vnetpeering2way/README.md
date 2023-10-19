## Create Virtual Network Peerings between two Virtual Networks
This module helps create virtual network peering across same region, different region and different subscriptions too. Virtual network peering enables you to seamlessly connect two Azure virtual networks. Once peered, the virtual networks appear as one, for connectivity purposes. The traffic between virtual machines in the peered virtual networks is routed through the Microsoft backbone infrastructure, much like traffic is routed between virtual machines in the same virtual network, through private IP addresses only. Azure supports:

- VNet peering - connecting VNets within the same Azure region
- Global VNet peering - connecting VNets across Azure regions
- Cross Subscription peering - connecting VNets across different subscriptions

## Usage


```hcl
resource "random_id" "rg_name1" {
  byte_length = 8
}

resource "random_id" "rg_name2" {
  byte_length = 8
}

resource "azurerm_resource_group" "rg1" {
  name     = "${random_id.rg_name1.hex}"
  location = "${var.location1}"
}

resource "azurerm_resource_group" "rg2" {
  name     = "${random_id.rg_name2.hex}"
  location = "${var.location2}"
}

# First VNET
module "network1" {
  source              = "Azure/network/azurerm"
  resource_group_name = "${random_id.rg_name1.hex}"
  location            = "${var.location1}"
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

# Second VNET
module "network2" {
  source              = "Azure/network/azurerm"
  resource_group_name = "${random_id.rg_name2.hex}"
  location            = "${var.location2}"
  address_space       = "10.2.0.0/16"
  subnet_prefixes     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

# Creates VNET peerings from First VNET to Second VNET and also from Second VNET to First VNET
module "vnetpeering" {
  source               = "../.."
  vnet_peering_names   = ["vnetpeering1", "vnetpeering2"]
  vnet_names           = ["${module.network1.vnet_name}", "${module.network2.vnet_name}"]
  resource_group_names = ["${random_id.rg_name1.hex}", "${random_id.rg_name2.hex}"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}