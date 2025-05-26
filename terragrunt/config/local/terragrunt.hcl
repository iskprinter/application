
locals {
  env_vars = {
    cloudnative_pg_replicas           = 1
    cloudnative_pg_storage_capacity   = "1Gi"
    cloudnative_pg_storage_class_name = "local"
    kubectl_context_name              = "local"
  }
  global_vars = read_terragrunt_config(find_in_parent_folders("root.hcl")).locals
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      backend "local" {
        path = "${get_env("HOME")}/.terraform-state/iskprinter/application/local.json"
      }
    }
  EOF
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    resource "kubernetes_namespace" "iskprinter" {
      metadata {
        name = "${local.global_vars.namespace}"
      }
    }

    module "cloudnative_pg" {
      depends_on = [
        kubernetes_namespace.iskprinter
      ]
      namespace          = ${jsonencode(local.global_vars.namespace)}
      source             = "../../modules/cloudnative-pg"
      replicas           = ${jsonencode(local.env_vars.cloudnative_pg_replicas)}
      storage_capacity   = ${jsonencode(local.env_vars.cloudnative_pg_storage_capacity)}
      storage_class_name = ${jsonencode(local.env_vars.cloudnative_pg_storage_class_name)}
    }

    module "data_downloader" {
      depends_on = [
        module.cloudnative_pg
      ]
      namespace = ${jsonencode(local.global_vars.namespace)}
      source    = "../../modules/data-downloader"
    }
  EOF
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      config_path    = "~/.kube/config"
      config_context = ${jsonencode(local.env_vars.kubectl_context_name)}
    }
  EOF
}

generate "terraform" {
  path      = "terraform.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_providers {
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "~> 2.0"
        }
      }
      required_version = "~> 1.0"
    }
  EOF
}
