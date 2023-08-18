output "resource_group_name" {
  value = azurerm_resource_group.brilliorg
}

output "azurerm_postgresql_flexible_server" {
  value = azurerm_postgresql_server.postgresserver
  sensitive = true
}

output "postgresql_flexible_server_database_name" {
  value = azurerm_postgresql_database.db
}
