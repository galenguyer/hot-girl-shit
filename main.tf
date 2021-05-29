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

resource "azurerm_network_security_group" "nsg" {
    name                = "${var.rg_name}-nsg"
    location            = var.rg_region
    resource_group_name = azurerm_resource_group.rg.name

    # normal stuff
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "nic" {
    count                       = var.worker_count
    name                        = "${var.rg_name}-nic-${count.index}"
    location                    = var.rg_region
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "${var.rg_name}-nic-${count.index}-config"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_subnet_network_security_group_association" "nic-subnet-association" {
    subnet_id                 = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
    count                 = var.worker_count
    name                  = "${var.rg_name}-vm-${count.index}"
    location              = var.rg_region
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
    size                  = var.vm_size

    os_disk {
        name                 = "${var.rg_name}-vm-${count.index}-osdisk"
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Debian"
        offer     = "debian-10"
        sku       = "10"
        version   = "latest"
    }

    admin_username = var.username
    disable_password_authentication = true

    admin_ssh_key {
        username       = var.username
        public_key = file("~/.ssh/id_rsa.pub")
    }
}
