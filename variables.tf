variable "api_client_credentials_secret_name" {
  type    = string
  default = "api-client-credentials"
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

variable "mongodb_connection_url_base64" {
  type      = string
  sensitive = true
}

variable "mongodb_connection_secret_name" {
  type    = string
  default = "mongodb-connection"
}
