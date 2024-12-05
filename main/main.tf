terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>2.31.1"
        }
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rg" {
    name     = "demo_codewithai_github"
    location = "eastus"
}

resource "azurerm_storage_account" "sa" {
    name                     = "demostorageacctgithub"
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = azurerm_resource_group.rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
