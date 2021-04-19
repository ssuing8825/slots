resource "azurerm_application_insights" "appInsights" {
    name                = local.appInsightName
    location            = var.location
    resource_group_name = var.slotsRgName
    application_type    = "web"
}