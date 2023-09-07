resource "azurerm_resource_group" "brilliorg" {
  name     = "brilliorg"
  location = "East US"
}

resource "azurerm_postgresql_flexible_server" "default" {
  name                   =  "brillioflexserver"
  resource_group_name    = azurerm_resource_group.brilliorg.name
  location               = azurerm_resource_group.brilliorg.location
  version                = "13"
  administrator_login    = "adminTerraform"
  administrator_password = "Bri!!iouser2023"
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  geo_redundant_backup_enabled = true
  backup_retention_days  = 7
    identity {
    type = "SystemAssigned"
  }


  depends_on = [ azurerm_resource_group.brilliorg ]
}

resource "azurerm_postgresql_flexible_server_database" "default" {
  name      = "brillio-db"
  server_id = azurerm_postgresql_flexible_server.default.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
  depends_on = [ azurerm_postgresql_flexible_server.default ]
}
resource "azurerm_postgresql_flexible_server" "replica" {
  name                   =  "brillioflexserver1"
  resource_group_name    = azurerm_resource_group.brilliorg.name
  location               = azurerm_resource_group.brilliorg.location
  version                = "13"
  administrator_login    = "adminTerraform"
  administrator_password = "Bri!!iouser2023"
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7
  create_mode               = "Replica"
  source_server_id = azurerm_postgresql_flexible_server.default.id
  depends_on = [ azurerm_postgresql_flexible_server.default ]
    identity {
    type = "SystemAssigned"
  }
}
