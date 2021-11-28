variable "api_service_name" {
  type = string
}

variable "api_service_port" {
  type = number
}

variable "api_host" {
  type = string
}

variable "cert_issuer" {
  type = string
}

variable "frontend_host" {
  type = string
}

variable "frontend_service_name" {
  type = string
}

variable "frontend_service_port" {
  type = number
}

variable "gcp_project" {
  type = string
}

variable "google_dns_managed_zone_name" {
  type = string
}

variable "namespace" {
  type = string
}
