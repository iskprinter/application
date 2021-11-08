terraform {
  backend "gcs" {
    bucket = "iskprinter-tf-state-prod"
    prefix = "application"
  }
}

provider "kubernetes" {}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

module "db_document" {
  depends_on = [
    kubernetes_namespace.namespace
  ]
  source           = "./modules/db_document"
  namespace        = var.data_namespace
  mongodb_replicas = var.mongodb_replicas
  project          = var.gcp_project
  region           = var.region
}

module "db_graph" {
  depends_on = [
    kubernetes_namespace.namespace
  ]
  source                       = "./modules/db_graph"
  namespace                    = var.data_namespace
  neo4j_persistent_volume_size = var.neo4j_persistent_volume_size
  neo4j_release_name           = var.neo4j_release_name
  neo4j_replicas               = var.neo4j_replicas
  neo4j_version                = var.neo4j_version
  project                      = var.gcp_project
  region                       = var.region
}

module "connections" {
  source                            = "./modules/connections"
  mongodb_connection_url            = module.db_document.mongodb_connection_url
  mongodb_connection_secret_key_url = var.mongodb_connection_secret_key_url
  mongodb_connection_secret_name    = var.mongodb_connection_secret_name
  namespace                         = var.namespace
}

module "api" {
  depends_on = [
    kubernetes_namespace.namespace
  ]
  source                                   = "./modules/api"
  api_client_credentials_secret_key_id     = var.api_client_credentials_secret_key_id
  api_client_credentials_secret_key_secret = var.api_client_credentials_secret_key_secret
  api_client_credentials_secret_name       = var.api_client_credentials_secret_name
  image                                    = var.image_api
  mongodb_connection_secret_key_url        = var.mongodb_connection_secret_key_url
  mongodb_connection_secret_name           = var.mongodb_connection_secret_name
  mongodb_connection_secret_version        = module.connections.mongodb_connection_secret_version
  namespace                                = var.namespace
}

module "frontend" {
  depends_on = [
    kubernetes_namespace.namespace
  ]
  source    = "./modules/frontend"
  namespace = var.namespace
  image     = var.image_frontend
}

module "ingress" {
  depends_on = [
    kubernetes_namespace.namespace
  ]
  source                       = "./modules/ingress"
  api_service_name             = module.api.service_name
  api_service_port             = module.api.service_port
  frontend_service_name        = module.frontend.service_name
  frontend_service_port        = module.frontend.service_port
  gcp_project                  = var.gcp_project
  google_dns_managed_zone_name = var.google_dns_managed_zone_name
  namespace                    = var.namespace
}

module "weekly_download" {
  depends_on = [
    kubernetes_namespace.namespace
  ]
  source                            = "./modules/weekly_download"
  image                             = var.image_weekly_download
  namespace                         = var.namespace
  mongodb_connection_secret_name    = var.mongodb_connection_secret_name
  mongodb_connection_secret_key_url = var.mongodb_connection_secret_key_url
}
