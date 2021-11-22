variable "env_name" {
  type = string
}

variable "frontend_host" {
  type = string
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

# Defaults

variable "api_client_credentials_secret_namespace" {
  type    = string
  default = "secrets"
}

variable "api_client_credentials_secret_key_id" {
  type    = string
  default = "id"
}

variable "api_client_credentials_secret_key_secret" {
  type    = string
  default = "secret"
}

variable "api_client_credentials_secret_name" {
  type    = string
  default = "api-client-credentials"
}

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

variable "mongodb_replicas" {
  type    = number
  default = 2
}

variable "neo4j_persistent_volume_size" {
  type    = string
  default = "10Gi"
}

variable "neo4j_release_name" {
  type    = string
  default = "neo4j"
}

variable "neo4j_replicas" {
  type    = number
  default = 2
}

variable "neo4j_version" {
  type    = string
  default = "4.3.4" # The Neo4j version.
}

variable "region" {
  type    = string
  default = "us-west1"
}
