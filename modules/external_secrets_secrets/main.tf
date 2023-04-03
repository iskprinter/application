resource "kubectl_manifest" "api_client_credentials" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "ExternalSecret"
    type       = "Opaque"
    metadata = {
      namespace = var.namespace
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

resource "kubectl_manifest" "iskprinter_jwt_keys" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "ExternalSecret"
    type       = "Opaque"
    metadata = {
      namespace = var.namespace
      name      = "iskprinter-jwt-keys"
    }
    spec = {
      secretStoreRef = {
        name = "hashicorp-vault-kv"
        kind = "ClusterSecretStore"
      }
      target = {
        name = "iskprinter-jwt-keys"
      }
      data = [
        {
          secretKey = "privateKey"
          remoteRef = {
            key      = "secret/${var.env_name}/iskprinter-jwt-keys"
            property = "private-key"
          }
        },
        {
          secretKey = "publicKey"
          remoteRef = {
            key      = "secret/${var.env_name}/iskprinter-jwt-keys"
            property = "public-key"
          }
        }
      ]
      refreshInterval = "5s"
    }
  })
}
