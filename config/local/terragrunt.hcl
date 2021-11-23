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
    prefix               = "application/local/${run_cmd("whoami")}"
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
}

generate "main" {
  path      = "terragrunt_generated_main.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<-EOF

    data "google_client_config" "provider" {}

    data "google_container_cluster" "general_purpose" {
      project  = "cameronhudson8"
      location = "us-west1"
      name     = "general-purpose-cluster"
    }

    provider "kubernetes" {
      config_context = "minikube"
      experiments {
        manifest_resource = true
      }
    }

    provider "helm" {
      kubernetes {
        config_context = "minikube"
      }
    }

    module "main" {
      source = "../../"
      api_host      = "api.local.iskprinter.com"
      namespace     = "iskprinter-local"
      frontend_host = "local.iskprinter.com"
    }

    EOF
}
