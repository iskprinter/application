output "api_client_credentials_secret_name" {
  value = kubernetes_secret.api_client_credentials.metadata[0].name
}

output "api_client_credentials_secret_key_id" {
  value = local.api_client_credentials_secret_key_id
}

output "api_client_credentials_secret_key_secret" {
  value = local.api_client_credentials_secret_key_secret
}

output "mongodb_connection_secret_name" {
  value = kubernetes_secret.mongodb_connection.metadata[0].name
}

output "mongodb_connection_secret_key_url" {
  value = local.mongodb_connection_secret_key_url
}
