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
    name     = "newdemo_codewithai_github"
    location = "eastus"
}

resource "azurerm_storage_account" "sa" {
    name                     = "optumstorageacctgithub"
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = azurerm_resource_group.rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "vnet" {
    name                = "example-vnet-demo1234"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
    name                 = "example-subnet-demo1234"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "private_dns" {
    name                = "privatelink.blob.core.windows.net"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
    name                  = "example-link-demo1234"
    resource_group_name   = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
    virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "private_endpoint" {
    name                = "example-private-endpoint-demo1234"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    subnet_id           = azurerm_subnet.subnet.id

    private_service_connection {
        name                           = "example-privateserviceconnection-demo1234"
        private_connection_resource_id = azurerm_storage_account.sa.id
        subresource_names              = ["blob"]
        is_manual_connection           = false
    }
}

resource "azurerm_private_dns_a_record" "dns_a_record" {
    name                = azurerm_storage_account.sa.name
    zone_name           = azurerm_private_dns_zone.private_dns.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl                 = 300
    records             = [azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address]
}
