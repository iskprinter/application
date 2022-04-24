resource "kubectl_manifest" "api_client_credentials" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "ExternalSecret"
    type       = "Opaque"
    metadata = {
      namespace = "iskprinter"
      name      = "api-client-credentials"
    }
    spec = {
      secretStoreRef = {
        name = "hashicorp-vault-kv"
        kind = "ClusterSecretStore"
      }
      target = {
        name = "api-client-credentials"
      }
      data = [
        {
          secretKey = "id"
          remoteRef = {
            key      = "secret/${var.env_name}/api-client-credentials"
            property = "id"
          },
        },
        {
          secretKey = "secret"
          remoteRef = {
            key      = "secret/${var.env_name}/api-client-credentials"
            property = "secret"
          }
        }
      ]
      refreshInterval = "5s"
    }
  })
}