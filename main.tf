module "namespaces" {
  source    = "./modules/namespaces"
  namespace = var.namespace
}

module "operator_mongodb" {
  # This currently causes an error due to a bug in the kubectl provider
  # depends_on = [  
  #   module.namespaces
  # ]
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
  source                       = "./modules/db_graph"
  gcp_project                  = var.gcp_project
  namespace                    = var.namespace
  persistent_volume_size = var.neo4j_persistent_volume_size
  replica_count          = var.neo4j_replica_count
  neo4j_version                = var.neo4j_version
  region                       = var.region
}

module "api" {
  depends_on = [
    module.namespaces
  ]
  source                                   = "./modules/api"
  api_client_credentials_secret_key_id     = var.api_client_credentials_secret_key_id
  api_client_credentials_secret_key_secret = var.api_client_credentials_secret_key_secret
  api_client_credentials_secret_name       = var.api_client_credentials_secret_name
  api_client_credentials_secret_namespace  = var.api_client_credentials_secret_namespace
  image                                    = var.image_api
  mongodb_connection_secret_key_url        = module.db_document.mongodb_connection_secret_key_url
  mongodb_connection_secret_name           = module.db_document.mongodb_connection_secret_name
  mongodb_connection_secret_version        = module.db_document.mongodb_connection_secret_version
  namespace                                = var.namespace
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
  source    = "./modules/frontend"
  image     = var.image_frontend
  namespace = var.namespace
  api_host  = var.api_host
}

module "ingress" {
  depends_on = [
    module.namespaces
  ]
  source                       = "./modules/ingress"
  api_host                     = var.api_host
  api_service_name             = module.api.service_name
  api_service_port             = module.api.service_port
  frontend_host                = var.frontend_host
  frontend_service_name        = module.frontend.service_name
  frontend_service_port        = module.frontend.service_port
  gcp_project                  = var.gcp_project
  google_dns_managed_zone_name = var.google_dns_managed_zone_name
  namespace                    = var.namespace
}

module "acceptance_test" {
  depends_on = [
    module.namespaces,
    module.db_document,
    module.db_graph,
    module.api,
    module.weekly_download,
    module.frontend,
    module.ingress,
  ]
  source        = "./modules/acceptance_test"
  image         = var.image_acceptance_test
  namespace     = var.namespace
  frontend_host = var.frontend_host
}
