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
  api_host                       = "api.iskprinter.com"
  api_replicas                   = 2
  cert_manager_issuer_name       = "lets-encrypt"
  create_namespace               = true
  frontend_host                  = "iskprinter.com"
  frontend_replicas              = 2
  mongodb_persistent_volume_size = "10Gi"
  mongodb_replica_count          = 2
  neo4j_persistent_volume_size   = "10Gi"
  neo4j_replica_count            = 2
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
