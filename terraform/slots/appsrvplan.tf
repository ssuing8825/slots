resource "azurerm_app_service_plan" "appSrvcPlan" {
    name                    = local.appSrvcPlanName
    resource_group_name     = var.slotsRgName
    location                = var.location
    kind                    = var.appPlanKind
    sku {
        tier = var.appSkuTier
        size = var.appPlanSize
    }
}

resource "azurerm_function_app" "funcApp" {
    name                        = local.funcAppName
    resource_group_name         = var.ghkoatRgName
    location                    = var.location
    app_service_plan_id         = azurerm_app_service_plan.appSrvcPlan.id
    storage_account_name        = azurerm_storage_account.funcAppSa.name
    storage_account_access_key  = azurerm_storage_account.funcAppSa.primary_access_key
    depends_on                  = [azurerm_application_insights.appInsights]
    https_only                  = true
    version                     = "~3"

    site_config {
    #   ip_restriction = [
    #     {
    #       action    = "Allow"
    #       name      = "COSMOS_DB_ALLOW_IN"
    #       priority  = 101
    #       virtual_network_subnet_id = data.azurerm_subnet.cosmos.id
    #       subnet_id = null
    #       ip_address = null
    #       service_tag = null
    #     },
    #     {
    #       action = "Allow"
    #       name = "WEBAPP_ALLOW_IN"
    #       virtual_network_subnet_id = data.azurerm_subnet.appSrvc.id
    #       priority = 102
    #       subnet_id = null
    #       ip_address = null
    #       service_tag = null
    #     },
    #     {
    #       action = "Allow"
    #       name = "APIM_ALLOW_IN"
    #       virtual_network_subnet_id = data.azurerm_subnet.api.id
    #       priority = 103
    #       subnet_id = null
    #       ip_address = null
    #       service_tag = null
    #     }
    #   ]
    #   always_on = true
      cors {
        allowed_origins = [ local.webAppUrl ] 
      }      
    }
    app_settings = {
      APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appInsights.instrumentation_key
  }        
}