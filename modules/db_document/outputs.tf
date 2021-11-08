output "mongodb_connection_url" {
  value     = "mongodb+srv://${urlencode(local.mongodb_user_api_username)}:${urlencode(random_password.mongodb_user_api_password.result)}@${local.mongodb_resource_name}-svc.${var.namespace}.svc.cluster.local/?ssl=false"
  sensitive = true
}
