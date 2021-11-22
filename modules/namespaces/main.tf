resource "kubernetes_namespace" "iskprinter" {
  metadata {
    name = var.namespace
  }
}
