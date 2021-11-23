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
    prefix               = "application/prod"
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
  api_host      = "api.iskprinter.com"
  namespace     = "iskprinter-prod"
  frontend_host = "iskprinter.com"
}

generate "providers" {
  path      = "terragrunt_generated_main.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<-EOF

    data "google_client_config" "provider" {}

    data "google_container_cluster" "general_purpose" {
      project  = "cameronhudson8"
      location = "us-west1-a"
      name     = "general-purpose-cluster"
    }

    provider "kubernetes" {
      host  = "https://$${data.google_container_cluster.general_purpose.endpoint}"
      token = data.google_client_config.provider.access_token
      cluster_ca_certificate = base64decode(data.google_container_cluster.general_purpose.master_auth[0].cluster_ca_certificate)
      experiments {
        manifest_resource = true
      }
    }

    provider "helm" {
      kubernetes {
        host  = "https://$${data.google_container_cluster.general_purpose.endpoint}"
        token = data.google_client_config.provider.access_token
        cluster_ca_certificate = base64decode(data.google_container_cluster.general_purpose.master_auth[0].cluster_ca_certificate)
      }
    }

    EOF
}
