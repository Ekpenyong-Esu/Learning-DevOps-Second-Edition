# This block defines an Azure Resource Group named "bookRg" located in the
# "West Europe" region. It also assigns a tag to the resource group with the key "environment" and
# the value "Terraform Azure".
resource "azurerm_resource_group" "rg" {     # rg is the tag for the resources group
  name     = "bookRg"
  location = "West Europe"

  tags = {
    environment = "Terraform Azure"          # This shows the environment of the resource group
  }
}

# This block defines an Azure Virtual Network named "book-vnet" with the address space "10.0.0.0/16".
# It's located in the same region as the resource group ("West Europe")
# and associated with the previously defined resource group (azurerm_resource_group.rg.name).
resource "azurerm_virtual_network" "vnet" {
  name                = "book-vnet"
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
}

# This block defines an Azure Subnet named "book-subnet" within the previously
# defined virtual network. It has the address prefix "10.0.10.0/24" and is
# associated with the same resource group.
resource "azurerm_subnet" "subnet" {
  name                 = "book-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes       = ["10.0.10.0/24"]
}

# This block defines an Azure Public IP address named "book-ip".
# It's allocated dynamically ("Dynamic") and associated with the same resource group.
# It also has a domain name label of "bookdevops".
resource "azurerm_public_ip" "pip" {
  name                         = "book-ip"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  allocation_method            = "Dynamic"
  domain_name_label            = "bookdevops"
}

# This block defines an Azure Network Interface named "book-nic".
# It's located in the same region and associated with the same resource group.
# It has an IP configuration with a dynamic private IP allocation and references
# the previously defined subnet and public IP resources.
# A network interface is a network interface card that enables a virtual machine (VM) or other
# Azure resources to communicate with the network and other resources.
resource "azurerm_network_interface" "nic" {
  name                = "book-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "bookipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# This block defines an Azure Storage Account named "bookstor". It's located in the
# same region and associated with the same resource group. It's configured with a
# standard tier and locally redundant storage ("LRS").
resource "azurerm_storage_account" "stor" {
  name                     = "bookstor"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# This block defines an Azure Virtual Machine named "bookvm". It's located in
# the same region and associated with the same resource group. It's configured
# with a specific VM size ("Standard_DS1_v2") and references the previously
# defined network interface for networking
resource "azurerm_virtual_machine" "vm" {
  name                = "bookvm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_size             = "Standard_DS1_v2"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "book-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "VMBOOK"
    admin_username = "admin"
    admin_password = "book123*"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.stor.primary_blob_endpoint
  }
}
