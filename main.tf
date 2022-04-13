module "namespaces" {
  source = "./modules/namespaces"
}

module "external_secrets" {
  source                   = "./modules/external_secrets"
  external_secrets_version = var.external_secrets_version
}

module "cert_manager" {
  source               = "./modules/cert_manager"
  cert_manager_version = var.cert_manager_version
  self_signed          = var.cert_manager_self_signed
  project              = var.project
}

module "operator_mongodb" {
  source    = "./modules/operator_mongodb"
  namespace = var.namespace
}

module "db_document" {
  depends_on = [
    module.namespaces,
    module.operator_mongodb
  ]
  source                 = "./modules/db_document"
  gcp_project            = var.gcp_project
  replica_count          = var.mongodb_replica_count
  persistent_volume_size = var.mongodb_persistent_volume_size
  namespace              = var.namespace
  region                 = var.region
}

module "db_graph" {
  depends_on = [
    module.namespaces
  ]
  source                 = "./modules/db_graph"
  gcp_project            = var.gcp_project
  namespace              = var.namespace
  persistent_volume_size = var.neo4j_persistent_volume_size
  replica_count          = var.neo4j_replica_count
  neo4j_version          = var.neo4j_version
  region                 = var.region
}

module "api" {
  depends_on = [
    module.namespaces
  ]
  source                            = "./modules/api"
  api_client_id                     = var.api_client_id
  api_client_secret                 = var.api_client_secret
  api_host                          = var.api_host
  frontend_host                     = var.frontend_host
  image                             = var.image_api
  mongodb_connection_secret_key_url = module.db_document.mongodb_connection_secret_key_url
  mongodb_connection_secret_name    = module.db_document.mongodb_connection_secret_name
  mongodb_connection_secret_version = module.db_document.mongodb_connection_secret_version
  namespace                         = var.namespace
  replicas                          = var.api_replicas
}

module "weekly_download" {
  depends_on = [
    module.namespaces
  ]
  source                            = "./modules/weekly_download"
  image                             = var.image_weekly_download
  mongodb_connection_secret_key_url = module.db_document.mongodb_connection_secret_key_url
  mongodb_connection_secret_name    = module.db_document.mongodb_connection_secret_name
  mongodb_connection_secret_version = module.db_document.mongodb_connection_secret_version
  namespace                         = var.namespace
}

module "frontend" {
  depends_on = [
    module.namespaces
  ]
  source        = "./modules/frontend"
  api_host      = var.api_host
  frontend_host = var.frontend_host
  image         = var.image_frontend
  namespace     = var.namespace
  replicas      = var.frontend_replicas
}

module "acceptance_test" {
  depends_on = [
    module.namespaces,
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
