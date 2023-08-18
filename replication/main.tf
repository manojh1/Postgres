resource "azurerm_resource_group" "brilliorg" {
  name     = "brilliorg"
  location = "East US"
}
resource "random_password" "psql_password" {
  length   = 20
  special  = true
}
resource "azurerm_key_vault" "brilliokv2" {
  name                     = "brilliokv2"
  location                 = azurerm_resource_group.brilliorg.location
  resource_group_name      = azurerm_resource_group.brilliorg.name
  tenant_id                = var.tenant_id
  sku_name                 = "premium"
  purge_protection_enabled = true
  depends_on = [ azurerm_resource_group.brilliorg ]
}

resource "azurerm_key_vault_access_policy" "server" {
  key_vault_id       = azurerm_key_vault.brilliokv2.id
  tenant_id          = var.tenant_id
  object_id          = azurerm_postgresql_server.postgresserver.identity.0.principal_id
  key_permissions    = ["Get", "UnwrapKey", "WrapKey"]
  secret_permissions = ["Get"]
  depends_on = [ azurerm_key_vault.brilliokv2 ]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id       = azurerm_key_vault.brilliokv2.id
  tenant_id          = var.tenant_id
  object_id          = azurerm_postgresql_server.postgresserver.identity[0].principal_id
  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
  depends_on = [ azurerm_key_vault.brilliokv2 ]
}

resource "azurerm_key_vault_key" "brilliokvkey" {
  name         = "tfex-key"
  key_vault_id = azurerm_key_vault.brilliokv2.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt","encrypt","sign","unwrapKey","verify","wrapKey"]
  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_key_vault_access_policy.server,
  ]
}
resource "azurerm_postgresql_server_key" "ok" {
  server_id        = azurerm_postgresql_server.postgresserver.id
  key_vault_key_id = azurerm_key_vault_key.brilliokvkey.id
  depends_on = [ azurerm_key_vault_key.brilliokvkey ]
}
resource "azurerm_postgresql_server" "postgresserver" {
  name                = "postgresql-tamops"
  location            = azurerm_resource_group.brilliorg.location
  resource_group_name = azurerm_resource_group.brilliorg.name 
  sku_name = "B_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
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
  name                = "postgresql-tamops-${each.key}"
  location            = azurerm_resource_group.brilliorg.location
  resource_group_name = azurerm_resource_group.brilliorg.name
  sku_name = "B_Gen5_2"
  version                      = "11"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  ssl_enforcement_enabled          = true
  administrator_login          = "psqladmin"
  administrator_login_password =  random_password.psql_password.result
  create_mode               = "Replica"
  creation_source_server_id = azurerm_postgresql_server.postgresserver.id
}
