locals {
  api_client_credentials_secret_key_id     = "id"
  api_client_credentials_secret_key_secret = "secret"
  mongodb_connection_secret_key_url        = "url"
}

resource "kubernetes_secret" "api_client_credentials" {
  type = "Opaque"
  metadata {
    namespace = var.namespace
    name      = "api-client-credentials"
  }
  binary_data = {
    (local.api_client_credentials_secret_key_id)     = base64encode(var.api_client_id)
    (local.api_client_credentials_secret_key_secret) = var.api_client_secret_base64
  }
}

resource "kubernetes_secret" "mongodb_connection" {
  type = "Opaque"
  metadata {
    namespace = var.namespace
    name      = "mongodb-connection"
  }
  binary_data = {
    (local.mongodb_connection_secret_key_url) = var.mongodb_connection_url_base64
  }
}
