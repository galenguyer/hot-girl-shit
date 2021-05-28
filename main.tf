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
