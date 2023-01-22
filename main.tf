module "external_secrets_secrets" {
  source    = "./modules/external_secrets_secrets"
  namespace = var.namespace
  env_name  = var.env_name
}

module "db_document" {
  source                 = "./modules/db_document"
  replica_count          = var.mongodb_replica_count
  persistent_volume_size = var.mongodb_persistent_volume_size
  namespace              = var.namespace
}

module "api" {
  source                            = "./modules/api"
  api_host                          = var.api_host
  cert_manager_issuer_name          = var.cert_manager_issuer_name
  cors_urls                         = var.allow_cors_localhost ? ["https://${var.frontend_host}", "http://localhost:4200"] : ["https://${var.frontend_host}"]
  image                             = var.image_api
  create_ingress                    = var.create_ingress
  mongodb_connection_secret_key_url = module.db_document.mongodb_connection_secret_key_url
  mongodb_connection_secret_name    = module.db_document.mongodb_connection_secret_name
  mongodb_connection_secret_version = module.db_document.mongodb_connection_secret_version
  namespace                         = var.namespace
  replicas                          = var.api_replicas
}

module "frontend" {
  source                   = "./modules/frontend"
  api_host                 = var.api_host
  frontend_host            = var.frontend_host
  cert_manager_issuer_name = var.cert_manager_issuer_name
  image                    = var.image_frontend
  create_ingress           = var.create_ingress
  namespace                = var.namespace
  replicas                 = var.frontend_replicas
}

module "acceptance_test" {
  depends_on = [
    module.db_document,
    module.api,
    module.frontend
  ]
  source    = "./modules/acceptance_test"
  image     = var.image_acceptance_test
  namespace = var.namespace
}
