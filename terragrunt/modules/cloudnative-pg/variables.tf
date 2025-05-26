variable "namespace" {
  description = "The namespace in which to deploy"
  type        = string
}

variable "replicas" {
  description = "The number of Postgres replicas"
  type        = number
}

variable "storage_capacity" {
  description = "The storage capacity to allocate"
  type        = string
}

variable "storage_class_name" {
  description = "The name of the storage class to use"
  type        = string
}
