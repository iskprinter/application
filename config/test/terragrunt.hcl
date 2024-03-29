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
    prefix               = "application/test-${run_cmd("--terragrunt-quiet", "whoami")}"
    skip_bucket_creation = true
  }
}

terraform {
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
    arguments = [
      "-lockfile=readonly",
    ]
  }
  source = "../..//."
}

inputs = {
  allow_cors_localhost           = true
  api_host                       = "api.iskprinter-test.com"
  api_replicas                   = 1
  cert_manager_issuer_name       = "self-signed"
  env_name                       = "test"
  frontend_host                  = "iskprinter-test.com"
  frontend_replicas              = 1
  create_ingress                 = true
  mongodb_persistent_volume_size = "1Gi"
  mongodb_replica_count          = 1
  namespace                      = "iskprinter"
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
      location = "us-west1"
      name     = "general-purpose-cluster"
    }

    provider "helm" {
      kubernetes {
      config_path = "~/.kube/config"
      config_context = "minikube"
      }
    }

    provider "kubectl" {
      config_path = "~/.kube/config"
      config_context = "minikube"
    }

    provider "kubernetes" {
      config_path = "~/.kube/config"
      config_context = "minikube"
    }

  EOF

}
