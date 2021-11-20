# Image Versions

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

variable "image_acceptance_test" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/acceptance-test:6dca43ce9b0e32918f1189670d674598d7840442"
}

# Basics

variable "gcp_project" {
  type    = string
  default = "cameronhudson8"
}

variable "region" {
  type    = string
  default = "us-west1"
}

variable "data_namespace" {
  type    = string
  default = "database"
}

variable "namespace" {
  type    = string
  default = "iskprinter"
}

variable "google_dns_managed_zone_name" {
  type    = string
  default = "iskprinter-com"
}

# Mongodb

variable "mongodb_connection_secret_key_url" {
  type = string
}

variable "mongodb_connection_secret_name" {
  type    = string
  default = "mongodb-connection"
}

variable "mongodb_replicas" {
  type    = number
  default = 2
}

# Neo4j

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

# Secrets

variable "api_client_credentials_secret_key_id" {
  type = string
}

variable "api_client_credentials_secret_key_secret" {
  type = string
}

variable "api_client_credentials_secret_name" {
  type = string
}
