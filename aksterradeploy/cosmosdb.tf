# resource "azurerm_cosmosdb_account" "acc" {

#   name                      = "${var.env}db"
#   location                  = azurerm_resource_group.rg.location
#   resource_group_name       = azurerm_resource_group.rg.name
#   offer_type                = "Standard"
#   kind                      = "MongoDB"
#   enable_automatic_failover = true

#   capabilities {
#     name = "EnableMongo"
#   }

#   consistency_policy {
#     consistency_level       = "BoundedStaleness"
#     max_interval_in_seconds = 400
#     max_staleness_prefix    = 100000
#   }

#   geo_location {
#     location          = var.failover_location
#     failover_priority = 1
#   }

#   geo_location {
#     location          = var.resource_group_location
#     failover_priority = 0
#   }
# }

# resource "azurerm_cosmosdb_mongo_database" "mongodb" {
#   name                = "cosmosmongodb"
#   resource_group_name = azurerm_cosmosdb_account.acc.resource_group_name
#   account_name        = azurerm_cosmosdb_account.acc.name
#   throughput          = 400
# }

# resource "azurerm_cosmosdb_mongo_collection" "coll" {
#   name                = "cosmosmongodbcollection"
#   resource_group_name = azurerm_cosmosdb_account.acc.resource_group_name
#   account_name        = azurerm_cosmosdb_account.acc.name
#   database_name       = azurerm_cosmosdb_mongo_database.mongodb.name

#   default_ttl_seconds = "777"
#   shard_key           = "uniqueKey"
#   throughput          = 400

#   lifecycle {
#     ignore_changes = [index]
#   }

#   depends_on = [azurerm_cosmosdb_mongo_database.mongodb]


# }