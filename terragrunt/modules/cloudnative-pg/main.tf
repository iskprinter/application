locals {
  replicas = 1
}

resource "kubernetes_manifest" "cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      namespace = var.namespace
      name      = "iskprinter"
    }
    spec = {
      instances = var.replicas
      storage = {
        size         = var.storage_capacity
        storageClass = var.storage_class_name
      }
    }
  }
}
