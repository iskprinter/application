output "mongodb_connection_secret_version" {
  value = kubernetes_secret.mongodb_connection.metadata[0].resource_version
}
