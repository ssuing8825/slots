terraform {
      backend "azurerm" {
    }

    required_providers {
        azurerm = {
            source   = "hashicorp/azurerm"
            version = ">=2.26.0"
        }
    }
}

module "slots" {
    source = "../slots"

    rgPrefix        = var.rgPrefix
    subId           = var.subId
    tenantId        = var.tenantId
    env             = var.env
    location        = var.location
    region          = var.region
    identifier      = var.identifier
    globalPrefix    = var.globalPrefix
    slotsRgName     = var.slotsRgName

    appPlanKind     = var.appPlanKind
    appSkuTier      = var.appSkuTier
    appPlanSize     = var.appPlanSize
    msftWebAppId    = var.msftWebAppId
}