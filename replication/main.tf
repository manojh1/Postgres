resource "azurerm_resource_group" "brilliorg" {
  name     = "brilliorg"
  location = "East US"
}
resource "random_password" "psql_password" {
  length   = 20
  special  = true
}

resource "azurerm_postgresql_server" "postgresserver" {
  name                = "postgresql-brillio"
  location            = azurerm_resource_group.brilliorg.location
  resource_group_name = azurerm_resource_group.brilliorg.name 
  sku_name = "B_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true
  administrator_login          = "psqladmin"
  administrator_login_password = random_password.psql_password.result
  version                      = "11"
  ssl_enforcement_enabled      = true
    identity {
    type = "SystemAssigned"
  }

}
resource "azurerm_postgresql_database" "db" {
  name                = "dbtest"
  resource_group_name = azurerm_resource_group.brilliorg.name
  server_name         = azurerm_postgresql_server.postgresserver.name
  charset             = "UTF8"
  collation           = "en-GB"
  depends_on = [ azurerm_postgresql_server.postgresserver ]
}
resource "azurerm_postgresql_server" "replica" {
  for_each = toset(var.replicas)
  name                = "postgresql-brillio-${each.key}"
  location            = azurerm_resource_group.brilliorg.location
  resource_group_name = azurerm_resource_group.brilliorg.name
  sku_name = "B_Gen5_2"
  version                      = "11"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  ssl_enforcement_enabled          = true
  administrator_login          = "psqladmin"
  administrator_login_password =  random_password.psql_password.result
  create_mode               = "Replica"
  creation_source_server_id = azurerm_postgresql_server.postgresserver.id
}
