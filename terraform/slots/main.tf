provider azurerm {
    features {}
    skip_provider_registration = "true"
}

data "azurerm_client_config" "cfg" {}

# data "azurerm_subnet" "appSrvc"  {
#   name                 = azurerm_subnet.appSrvc.name
#   resource_group_name  = var.slotsRgName
#   virtual_network_name = azurerm_virtual_network.vnt.name
# }

# The Microsoft Global Web App Service Principal. This is needed for providing web apps to get values from Key Vault.
data "azuread_service_principal" "MicrosoftWebApp" {
  application_id = "abfa0a7c-a6b6-4736-8310-5855508787cd"
}