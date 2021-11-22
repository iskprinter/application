variable "gcp_project" {
  type = string
}

variable "namespace" {
  type = string
}

variable "neo4j_persistent_volume_size" {
  type = string
}

variable "neo4j_replicas" {
  type = number
}

variable "neo4j_release_name" {
  type = string
}

variable "neo4j_version" {
  type = string
}

variable "region" {
  type = string
}
