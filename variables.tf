variable "api_client_credentials_secret_name" {
  type    = string
  default = "api-client-credentials"
}

variable "api_uri_prefix" {
  type    = string
  default = "api"
}

variable "namespace" {
  type    = string
  default = "iskprinter"
}

variable "api_client_id" {
  type    = string
  default = "bf9674bde4cd432193ac5644daf38b07"
}

variable "api_client_secret_base64" {
  type      = string
  sensitive = true
}

variable "google_dns_managed_zone_name" {
  type    = string
  default = "iskprinter-com"
}

variable "image_api" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:a26d6ae594590c02e945debd38ae4f6a690101a1"
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

variable "mongodb_connection_url_base64" {
  type      = string
  sensitive = true
}

variable "mongodb_connection_secret_name" {
  type    = string
  default = "mongodb-connection"
}
