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
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:42cc3b4b4b9c1f85d85ef74be1e43e844d31bb06"
}

variable "image_frontend" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/frontend:72937523aafbf2f0d9aa45ba84a75d1329d7be20"
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
