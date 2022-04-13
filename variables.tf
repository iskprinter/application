variable "project" {
  default = "cameronhudson8"
  type    = string
}

variable "namespace" {
  default = "iskprinter"
  type    = string
}

# Variables provided by CI/CD

variable "api_client_id" {
  type = string
}

variable "api_client_secret" {
  type = string
}

# Variables provided by Terragrunt config

variable "api_host" {
  type = string
}

variable "api_replicas" {
  type = number
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
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/acceptance-test:1ef980b5645bebb21be394055fad80427951edd4"
}

variable "image_api" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:e5d7964adf20580021692bd7be1ae1b0301e48a3"
}

variable "image_frontend" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/frontend:e5b147c59acc0989555528d3117f69de87cb3d54"
}

variable "image_weekly_download" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/weekly-download:90edfe1c7757c4e701973166af53c77384013e16"
}

# External Secrets

variable "external_secrets_version" {
  default = "0.5.1"
  type    = string
}

# Cert Manager

variable "cert_manager_version" {
  default = "1.6.1"
  type    = string
}

variable "cert_manager_self_signed" {
  type = bool
}

# Defaults

variable "cicd_namespace" {
  type    = string
  default = "tekton-pipelines"
}

variable "cicd_bot_name" {
  type    = string
  default = "cicd-bot"
}

variable "gcp_project" {
  type    = string
  default = "cameronhudson8"
}

variable "google_dns_managed_zone_name" {
  type    = string
  default = "iskprinter-com"
}

variable "neo4j_version" {
  type    = string
  default = "4.4.0" # The Neo4j version.
}

variable "region" {
  type    = string
  default = "us-west1"
}
