terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.88.1"
    }
  }

  required_version = ">=0.15"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "terraform_rg"
  location = "eastus"
}

// create virtual network
resource "azurerm_virtual_network" "main" {
  name = "tf-vnet"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space = ["10.0.0.0/16"]
}

# create subnet
resource "azurerm_subnet" "main" {
  name = "tf-subnet"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.0.0/24"]
}

# creates nic
resource "azurerm_network_interface" "internal" {
  name = "tf-nic"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.main.id 
    private_ip_address_allocation = "Dynamic"
  }
}

#Creates Virtual Machine 
resource "azurerm_windows_virtual_machine" "main" {
  name = "learn-tf-vm-eu" 
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location 
  size = "Standard_B1s"
  admin_username = "user.admin" 
  admin_password = "Testing@1234"

  network_interface_ids = [
    azurerm_network_interface.internal.id
  ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2016-DataCenter"
    version = "latest"
  }
}
