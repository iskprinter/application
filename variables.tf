variable "api_client_credentials_secret_key_id" {
  type = string
}

variable "api_client_credentials_secret_key_secret" {
  type = string
}

variable "api_client_credentials_secret_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "iskprinter"
}

variable "google_dns_managed_zone_name" {
  type    = string
  default = "iskprinter-com"
}

variable "image_api" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:0078c47d619c3f3f6a7dc5fab241a5a7a6e19fd7"
}

variable "image_frontend" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/frontend:b8191b65583f0e7d53b88e3c9aede9df134bf40c"
}

variable "image_weekly_download" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/weekly-download:90edfe1c7757c4e701973166af53c77384013e16"
}

variable "gcp_project" {
  type    = string
  default = "cameronhudson8"
}

variable "mongodb_connection_secret_key_url" {
  type = string
}

variable "mongodb_connection_secret_name" {
  type = string
}
