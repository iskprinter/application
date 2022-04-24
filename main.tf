module "external_secrets_secrets" {
  source   = "./modules/external_secrets_secrets"
  env_name = var.env_name
}

module "db_document" {
  source                 = "./modules/db_document"
  replica_count          = var.mongodb_replica_count
  persistent_volume_size = var.mongodb_persistent_volume_size
  namespace              = var.namespace
}

module "db_graph" {
  source                 = "./modules/db_graph"
  namespace              = var.namespace
  persistent_volume_size = var.neo4j_persistent_volume_size
  replica_count          = var.neo4j_replica_count
  neo4j_version          = var.neo4j_version
}

module "api" {
  source                            = "./modules/api"
  api_host                          = var.api_host
  cert_manager_issuer_name          = var.cert_manager_issuer_name
  frontend_host                     = var.frontend_host
  image                             = var.image_api
  mongodb_connection_secret_key_url = module.db_document.mongodb_connection_secret_key_url
  mongodb_connection_secret_name    = module.db_document.mongodb_connection_secret_name
  mongodb_connection_secret_version = module.db_document.mongodb_connection_secret_version
  namespace                         = var.namespace
  replicas                          = var.api_replicas
}

module "weekly_download" {
  source                            = "./modules/weekly_download"
  image                             = var.image_weekly_download
  mongodb_connection_secret_key_url = module.db_document.mongodb_connection_secret_key_url
  mongodb_connection_secret_name    = module.db_document.mongodb_connection_secret_name
  mongodb_connection_secret_version = module.db_document.mongodb_connection_secret_version
  namespace                         = var.namespace
}

module "frontend" {
  source                   = "./modules/frontend"
  api_host                 = var.api_host
  frontend_host            = var.frontend_host
  cert_manager_issuer_name = var.cert_manager_issuer_name
  image                    = var.image_frontend
  namespace                = var.namespace
  replicas                 = var.frontend_replicas
}

module "acceptance_test" {
  depends_on = [
    module.db_document,
    module.db_graph,
    module.api,
    module.weekly_download,
    module.frontend
  ]
  source        = "./modules/acceptance_test"
  image         = var.image_acceptance_test
  namespace     = var.namespace
  frontend_host = var.frontend_host
}
