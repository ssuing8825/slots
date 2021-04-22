resource "azurerm_cosmosdb_account" "cosmosdbAcc" {
  name                = lower(local.cosmosdbName)
  location            = var.location
  resource_group_name = var.slotsRgName
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  public_network_access_enabled = true
#   ip_range_filter     = "173.73.110.43,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26,0.0.0.0"
#   is_virtual_network_filter_enabled = true
#   virtual_network_rule {
#     id = azurerm_subnet.api.id
#   }
#   virtual_network_rule {
#     id = azurerm_subnet.cosmos.id
#   }
#   virtual_network_rule {
#     id = azurerm_subnet.appSrvc.id
#   }

  enable_automatic_failover = var.cosmosDBfailover

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = "eastus"
    failover_priority = 1
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "sqlDb" {
  name                = lower(var.identifier)
  resource_group_name = var.slotsRgName
  account_name        = azurerm_cosmosdb_account.cosmosdbAcc.name
  depends_on          = [azurerm_cosmosdb_account.cosmosdbAcc]
}
resource "azurerm_cosmosdb_sql_container" "containers" {
  for_each            = local.sqlContainers
  name                = each.value.name
  resource_group_name = var.slotsRgName
  account_name        = azurerm_cosmosdb_account.cosmosdbAcc.name
  database_name       = azurerm_cosmosdb_sql_database.sqlDb.name
  partition_key_path  = each.value.keyPath
}