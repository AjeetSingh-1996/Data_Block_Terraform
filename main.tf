resource "azurerm_resource_group" "ajrg" {
  name     = "ajrg"
  location = "centralindia"

}
resource "azurerm_virtual_network" "ajvnet" {
  name                = "ajvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "centralindia"
  resource_group_name = "ajrg"
  depends_on          = [azurerm_resource_group.ajrg]
}

resource "azurerm_subnet" "ajsn" {
  name                 = "ajsn"
  resource_group_name  = "ajrg"
  virtual_network_name = "ajvnet"
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [azurerm_virtual_network.ajvnet]
}

resource "azurerm_public_ip" "ajpip" {
  name                = "ajpip"
  resource_group_name = "ajrg"
  location            = "centralindia"
  allocation_method   = "Static"

}

resource "azurerm_network_interface" "ajnic" {
  name                = "ajnic"
  location            = "centralindia"
  resource_group_name = "ajrg"

  ip_configuration {
    name                          = "ajip"
    subnet_id                     = data.azurerm_subnet.ajdata_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ajpip.id
  }
}

resource "azurerm_linux_virtual_machine" "ajvm" {
  name                = "ajvm"
  resource_group_name = azurerm_resource_group.ajrg.name
  location            = azurerm_resource_group.ajrg.location
  size                = "Standard_F2"
  admin_username      = data.azurerm_key_vault_secret.username.value
  admin_password      = data.azurerm_key_vault_secret.password.value
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.ajnic.id
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
