resource "azurerm_resource_group" "comm3" {
  for_each = var.comm3
  name     = "rg-${each.value.rgname}"
  location = each.value.rglocation
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
}

resource "azurerm_storage_account" "comm3" {
  for_each                 = var.comm3
  name                     = replace("sa${each.value.rgname}", "/\\W|_|\\s/", "")
  resource_group_name      = azurerm_resource_group.comm3[each.key].name
  location                 = each.value.rglocation
  account_replication_type = "GRS"
  account_tier             = "Standard"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
}

resource "azurerm_network_security_group" "comm3" {
  for_each            = var.comm3
  name                = "nsg-${each.value.rgname}"
  resource_group_name = azurerm_resource_group.comm3[each.key].name
  location            = each.value.rglocation
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
}

resource "azurerm_virtual_network" "comm3" {
  for_each            = var.comm3
  name                = "vn-${each.value.rgname}"
  resource_group_name = azurerm_resource_group.comm3[each.key].name
  location            = each.value.rglocation
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
  subnet {
    name           = "sn-${each.value.rgname}"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.comm3[each.key].id
  }
}
