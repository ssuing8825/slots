provider "azurerm" {
  version = ">=2.36.0"
  features {}
}

variable "env_prefix" {
    type = string  
}

variable "resource_group" {
    type = string
}

data "azurerm_resource_group" "slotsrg" {
  name = var.resource_group
}

locals {
  storage_name = "slotsrg${var.env_prefix}artifacts"
}

resource "azurerm_storage_account" "artifacts" {
  name                     = local.storage_name
  resource_group_name      = data.azurerm_resource_group.slotsrg.name
  location                 = data.azurerm_resource_group.slotsrg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "terraform_state" {
  name                  = "terraform-state"
  storage_account_name  = azurerm_storage_account.artifacts.name
}
