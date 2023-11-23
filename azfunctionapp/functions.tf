variable "resource_group_name_network" {
  type    = string
  default = "rg-functionapps"
}

variable "vnet_name" {
  default = "vnet-functionapps"
}

variable "region" {
  type    = string
  default = "australiaeast"
}

variable "subnet_id_ingress" {
  type    = string
  default = "/subscriptions/xxxxxxxxxxx/resourceGroups/rg-functionapps/providers/Microsoft.Network/virtualNetworks/vnet-functionapps/subnets/appservice-pe"
}

variable "subnet_id_egress" {
  type    = string
  default = "/subscriptions/xxxxxxxxxxx/resourceGroups/rg-functionapps/providers/Microsoft.Network/virtualNetworks/vnet-functionapps/subnets/appservice-vnet-integration"
}

#// 2. Function App Resource group and Storage accounts with shares
resource "azurerm_resource_group" "rg-functionapps-corp" {
  provider = azurerm.corpventure0002
  name     = "rg-functionapps-corp"
  location = var.region
}

resource "azurerm_storage_account" "sa" {
  provider                 = azurerm.corpventure0002
  name                     = "safadeploytest001"
  resource_group_name      = azurerm_resource_group.rg-functionapps-corp.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  #public_network_access_enabled   = false
  network_rules {
    default_action = "Deny"
    ip_rules       = ["125.236.218.41", "122.56.80.204", "121.74.185.149"]
    #virtual_network_subnet_ids = [var.subnet_id_ingress,var.subnet_id_egress]
  }
}

resource "azurerm_storage_share" "sashare" {
  provider             = azurerm.corpventure0002
  name                 = "sashare"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 5120
}

#// 3. Private Endpoints for Storage accounts (blob, file, table, queue)

resource "azurerm_private_endpoint" "pe-function-app-blob" {
  provider            = azurerm.connectivity
  name                = "pe-function-app-blob"
  location            = var.region
  resource_group_name = var.resource_group_name_network
  subnet_id           = var.subnet_id_ingress

  private_service_connection {
    name                           = "pe-blob"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  private_dns_zone_group {
    name = "blob"
    private_dns_zone_ids = [
      "/subscriptions/xxxxxxxxxxx/resourceGroups/eslz-tf-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
    ]
  }
  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

resource "azurerm_private_endpoint" "pe-function-app-file" {
  provider            = azurerm.connectivity
  name                = "pe-function-app-file"
  location            = var.region
  resource_group_name = var.resource_group_name_network
  subnet_id           = var.subnet_id_ingress

  private_service_connection {
    name                           = "pe-file"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
  private_dns_zone_group {
    name = "file"
    private_dns_zone_ids = [
      "/subscriptions/xxxxxxxxxxx/resourceGroups/eslz-tf-dns/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
    ]
  }
  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

resource "azurerm_private_endpoint" "pe-function-app-queue" {
  provider            = azurerm.connectivity
  name                = "pe-function-app-queue"
  location            = var.region
  resource_group_name = var.resource_group_name_network
  subnet_id           = var.subnet_id_ingress

  private_service_connection {
    name                           = "pe-queue"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }
  private_dns_zone_group {
    name = "queue"
    private_dns_zone_ids = [
      "/subscriptions/xxxxxxxxxxx/resourceGroups/eslz-tf-dns/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net"
    ]
  }
  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

resource "azurerm_private_endpoint" "pe-function-app-table" {
  provider            = azurerm.connectivity
  name                = "pe-function-app-table"
  location            = var.region
  resource_group_name = var.resource_group_name_network
  subnet_id           = var.subnet_id_ingress

  private_service_connection {
    name                           = "pe-table"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }
  private_dns_zone_group {
    name = "table"
    private_dns_zone_ids = [
      "/subscriptions/xxxxxxxxxxx/resourceGroups/eslz-tf-dns/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net"
    ]
  }
  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

#// 4. App Service Plan (EP1)

resource "azurerm_service_plan" "appsp-ep" {
  provider            = azurerm.corpventure0002
  name                = "appsp-ep"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg-functionapps-corp.name
  os_type             = "Windows"
  sku_name            = "EP1"
}

#// 5. Function apps, each mapped to different ingress and egress subnets (same VNET)

resource "azurerm_windows_function_app" "fa-corpventure02" {
  provider                   = azurerm.corpventure0002
  name                       = "fa-corpventure02"
  resource_group_name        = azurerm_resource_group.rg-functionapps-corp.name
  location                   = var.region
  service_plan_id            = azurerm_service_plan.appsp-ep.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  https_only                 = true
  # storage_uses_managed_identity = true
  # identity {
  #   type = "SystemAssigned"
  # }
  virtual_network_subnet_id = var.subnet_id_egress
  site_config {
    pre_warmed_instance_count = 2
    vnet_route_all_enabled    = true
    # application_insights_connection_string = "InstrumentationKey=xxxxxxxxxxx;IngestionEndpoint=https://australiaeast-1.in.applicationinsights.azure.com/;LiveEndpoint=https://australiaeast.livediagnostics.monitor.azure.com/"
    application_insights_key = "xxxxxxxxxxx"
  }
  app_settings = {
    WEBSITE_CONTENTOVERVNET                  = 1
    WEBSITE_CONTENTSHARE                     = azurerm_storage_share.sashare.name
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = azurerm_storage_account.sa.primary_connection_string
    FUNCTIONS_WORKER_RUNTIME                 = "dotnet-isolated"
    FUNCTIONS_EXTENSION_VERSION              = "~4"
  }
}

# resource "azapi_update_resource" "this" {
#   type = "Microsoft.Web/sites/config@2022-03-01"
#   name = "web"
#   #resource_id = azurerm_windows_function_app.fa-corpventure02.id
#   parent_id = azurerm_windows_function_app.fa-corpventure02.id
#   body = jsonencode({
#     properties = {
#       netFrameworkVersion = "v6.0"
#     }
#   })
# }

resource "azurerm_private_endpoint" "fa-corpventure02" {
  provider            = azurerm.connectivity
  name                = "pe-fa-corpventure02"
  location            = var.region
  resource_group_name = var.resource_group_name_network
  subnet_id           = var.subnet_id_ingress
  private_service_connection {
    name                           = "pe-fa-corpventure02-privateconnection"
    private_connection_resource_id = azurerm_windows_function_app.fa-corpventure02.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name = "sites"
    private_dns_zone_ids = [
      "/subscriptions/xxxxxxxxxxx/resourceGroups/eslz-tf-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
    ]
  }
}

