resource "azurerm_storage_account" "funcAppSa" {
  name                      = local.saFuncAppName
  resource_group_name       = var.slotsRgName
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2" 
}
