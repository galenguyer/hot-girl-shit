terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.57"
    }
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_region
}

resource "azurerm_virtual_network" "vnet" {
 name                = "${var.rg_name}-vnet"
 address_space       = ["10.0.0.0/16"]
 location            = var.rg_region
 resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
 name                 = "${var.rg_name}-subnet"
 resource_group_name  = azurerm_resource_group.rg.name
 virtual_network_name = azurerm_virtual_network.vnet.name
 address_prefixes     = ["10.0.0.0/16"]
}
