output "mongodb_connection_secret_key_url" {
  value = local.mongodb_connection_secret_key_url
}

output "mongodb_connection_secret_name" {
  value = kubernetes_secret.mongodb_connection.metadata[0].name
}

output "mongodb_connection_secret_version" {
  value = kubernetes_secret.mongodb_connection.metadata[0].resource_version
}
