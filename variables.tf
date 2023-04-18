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
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:ebf0f9a2012fd374feeac4c45b50815b6656f1b9"
}

variable "image_frontend" {
  type    = string
  default = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/frontend:bff0bc1fcbcf72491355600a949346a2f21518c4"
}
