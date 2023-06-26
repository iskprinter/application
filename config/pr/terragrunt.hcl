remote_state {
  backend = "gcs"
  generate = {
    path      = "terragrunt_generated_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    project              = "cameronhudson8"
    location             = "us-west1"
    bucket               = "iskprinter-tf-state"
    prefix               = "application/pr-${get_env("PR_NUMBER")}"
    skip_bucket_creation = true
  }
}

generate "providers" {
  path      = "terragrunt_generated_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<-EOF

    terraform {
      required_version = ">= 0.13"
      required_providers {
        kubectl = {
          source  = "gavinbunney/kubectl"
          version = ">= 1.7.0"
        }
      }
    }

    data "google_client_config" "provider" {}

    data "google_container_cluster" "general_purpose" {
      project  = "cameronhudson8"
      location = "us-west1-a"
      name     = "general-purpose-cluster"
    }

    provider "helm" {
      kubernetes {
        host                   = "https://$${data.google_container_cluster.general_purpose.endpoint}"
        token                  = data.google_client_config.provider.access_token
        cluster_ca_certificate = base64decode(data.google_container_cluster.general_purpose.master_auth[0].cluster_ca_certificate)
      }
    }

    provider "kubectl" {
      host                   = "https://$${data.google_container_cluster.general_purpose.endpoint}"
      token                  = data.google_client_config.provider.access_token
      cluster_ca_certificate = base64decode(data.google_container_cluster.general_purpose.master_auth[0].cluster_ca_certificate) 
      load_config_file       = false
    }

    provider "kubernetes" {
      host                   = "https://$${data.google_container_cluster.general_purpose.endpoint}"
      token                  = data.google_client_config.provider.access_token
      cluster_ca_certificate = base64decode(data.google_container_cluster.general_purpose.master_auth[0].cluster_ca_certificate)
      experiments {
        manifest_resource = true
      }
    }

  EOF
}

generate "modules" {
  path      = "terragrunt_generated_modules.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<-EOF

    locals {
      allow_cors_localhost           = false
      api_host                       = "api.iskprinter-pr-${get_env("PR_NUMBER")}.com"
      api_replicas                   = 1
      cert_manager_issuer_name       = "self-signed"
      create_ingress                 = false
      frontend_host                  = "iskprinter-pr-${get_env("PR_NUMBER")}.com"
      frontend_replicas              = 1
      acceptance_test_image          = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/acceptance-test:24304476486b0afaa69919cb036b5b9e1a411980"
      api_image                      = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:34945807ff2596fbd68b4f2164f08ee2a5cbb3f3"
      frontend_image                 = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/frontend:914721f4c6e149f9943e2ebc10b04714eb510622"
      mongodb_persistent_volume_size = "1Gi"
      mongodb_replica_count          = 1
      mongodb_version                = "6.0.6"
      namespace_name                 = "iskprinter-pr-${get_env("PR_NUMBER")}"
    }

    module "namespace" {
      source = "../../modules/namespace"
      name   = local.namespace_name
    }

    module "external_secrets_secrets" {
      depends_on = [
        module.namespace
      ]
      source    = "../../modules/external_secrets_secrets"
      namespace = local.namespace_name
    }

    module "db_document" {
      depends_on = [
        module.namespace
      ]
      source                 = "../../modules/db_document"
      mongodb_version        = local.mongodb_version
      namespace              = local.namespace_name
      persistent_volume_size = local.mongodb_persistent_volume_size
      replica_count          = local.mongodb_replica_count
    }

    module "api" {
      depends_on = [
        module.namespace
      ]
      source                            = "../../modules/api"
      api_host                          = local.api_host
      cert_manager_issuer_name          = local.cert_manager_issuer_name
      cors_urls                         = local.allow_cors_localhost ? ["https://$${local.frontend_host}", "http://localhost:4200"] : ["https://$${local.frontend_host}"]
      image                             = local.api_image
      create_ingress                    = local.create_ingress
      mongodb_connection_secret_key_url = module.db_document.mongodb_connection_secret_key_url
      mongodb_connection_secret_name    = module.db_document.mongodb_connection_secret_name
      mongodb_connection_secret_version = module.db_document.mongodb_connection_secret_version
      namespace                         = local.namespace_name
      replicas                          = local.api_replicas
    }

    module "frontend" {
      depends_on = [
        module.namespace
      ]
      source                   = "../../modules/frontend"
      api_host                 = local.api_host
      frontend_host            = local.frontend_host
      cert_manager_issuer_name = local.cert_manager_issuer_name
      image                    = local.frontend_image
      create_ingress           = local.create_ingress
      namespace                = local.namespace_name
      replicas                 = local.frontend_replicas
    }

    module "acceptance_test" {
      depends_on = [
        module.api,
        module.db_document,
        module.frontend,
        module.namespace
      ]
      source    = "../../modules/acceptance_test"
      image     = local.acceptance_test_image
      namespace = local.namespace_name
    }

  EOF
}
