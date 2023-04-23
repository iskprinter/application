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

# Images

variable "image_acceptance_test" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/acceptance-test:24304476486b0afaa69919cb036b5b9e1a411980"
}

variable "image_api" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:34945807ff2596fbd68b4f2164f08ee2a5cbb3f3"
}

variable "image_frontend" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/frontend:914721f4c6e149f9943e2ebc10b04714eb510622"
}
