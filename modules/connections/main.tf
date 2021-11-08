resource "kubernetes_secret" "mongodb_connection" {
  type = "Opaque"
  metadata {
    namespace = var.namespace
    name      = var.mongodb_connection_secret_name
  }
  binary_data = {
    (var.mongodb_connection_secret_key_url) = base64encode(var.mongodb_connection_url)
  }
}
