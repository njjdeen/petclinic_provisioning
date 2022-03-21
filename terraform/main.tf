# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
  #subscription_id = "41e50375-b926-4bc4-9045-348f359cf721"
  #tenant_id       = "f82b3c62-b635-402b-afa2-a1a807bbfd42"
  #object_id       = ""
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  tags = {
    environment = "Test"
  }
}

#Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Test"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = var.network_security_group_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

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

  tags = {
    environment = "Test"
  }
}

# create network interface

resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    environment = "Test"
  }

}

#connect security group to network interface

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "random_id" "randomID" {
  keepers = {
    resource_group = var.resource_group_name
  }
  byte_length = 8
}

# create storage account for boot diagnostics

resource "azurerm_storage_account" "storage" {
  name                     = "diag${random_id.randomID.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = { environment = "Test" }
}

# Create and display SSH key

resource "tls_private_key" "ssh_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.linuxvm.public_ip_address
  sensitive = false
}

output "tls_private_key" {
  value = tls_private_key.ssh_rsa.private_key_pem 
  sensitive = true
  }
# create virtual machine

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                  = var.linux_virtual_machine_name
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    sku       = "20_04-lts-gen2"
    offer     = "0001-com-ubuntu-server-focal"
    version   = "latest"
  }

  computer_name                   = "TestEnvironmentVM"
  admin_username                  = "VMadmin"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "VMadmin"
    public_key = tls_private_key.ssh_rsa.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage.primary_blob_endpoint
  }

  tags = {
    environment = "Test"
  }
}


