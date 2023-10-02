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
    prefix               = "application/dev-${run_cmd("--terragrunt-quiet", "whoami")}"
    skip_bucket_creation = true
  }
}

generate "providers" {
  path      = "terragrunt_generated_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<-EOF

    provider "kubernetes" {
      config_path = "~/.kube/config"
      config_context = "minikube"
    }

  EOF
}

generate "modules" {
  path      = "terragrunt_generated_modules.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<-EOF

    locals {
      allow_cors_localhost           = true
      api_host                       = "api.iskprinter-dev.com"
      api_replicas                   = 1
      cert_manager_issuer_name       = "self-signed"
      create_ingress                 = true
      frontend_host                  = "iskprinter-dev.com"
      frontend_replicas              = 1
      acceptance_test_image          = "${get_env("ACCEPTANCE_TEST_IMAGE", "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/acceptance-test:4b3cd8e096b0a913df7949658efedeff722d26df")}"
      api_image                      = "${get_env("API_IMAGE", "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:25503e5e353ea05efe3c9a57f4a70d6f41565ea2")}"
      frontend_image                 = "${get_env("FRONTEND_IMAGE", "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/frontend:f9b287e7df94e714f86aac90ce197a0babd415f8")}"
      mongodb_persistent_volume_size = "1Gi"
      mongodb_replica_count          = 1
      mongodb_version                = "6.0.6"
      namespace_name                 = "iskprinter"
    }

    module "namespace" {
      source = "../../modules/namespace"
      name   = local.namespace_name
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
        module.namespace,
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
        module.namespace,
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