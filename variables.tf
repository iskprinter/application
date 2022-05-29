# Variables provided by Terragrunt config

variable "namespace" {
  type = string
}

variable "create_ingress" {
  type = string
}

variable "allow_cors_localhost" {
  type = bool
}

variable "api_host" {
  type = string
}

variable "api_replicas" {
  type = number
}

variable "cert_manager_issuer_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "frontend_host" {
  type = string
}

variable "frontend_replicas" {
  type = number
}

variable "mongodb_replica_count" {
  type = number
}

variable "mongodb_persistent_volume_size" {
  type = string
}

variable "neo4j_persistent_volume_size" {
  type = string
}

variable "neo4j_replica_count" {
  type = number
}

# Images

variable "image_acceptance_test" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/acceptance-test:24304476486b0afaa69919cb036b5b9e1a411980"
}

variable "image_api" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:5c3c6fbe08e04243996a878e3b56be575c31371e"
}

variable "image_frontend" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/frontend:94cc46f16933b7533a4be5c6743656fd2b0e55a4"
}

variable "image_weekly_download" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/weekly-download:e8330ea2b1fbb932c5fcd15964d7f4caff6517c2"
}

# Defaults

variable "neo4j_version" {
  type    = string
  default = "4.4.0" # The Neo4j version.
}
