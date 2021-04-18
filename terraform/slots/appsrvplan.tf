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