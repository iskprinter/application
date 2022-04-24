variable "api_host" {
  type = string
}

variable "cert_manager_issuer_name" {
  type = string
}

variable "frontend_host" {
  type = string
}

variable "image" {
  type = string
}

variable "create_ingress" {
  type = string
}

variable "namespace" {
  type = string
}

variable "mongodb_connection_secret_name" {
  type = string
}

variable "mongodb_connection_secret_key_url" {
  type = string
}

variable "mongodb_connection_secret_version" {
  type = string
}

variable "replicas" {
  type = number
}
