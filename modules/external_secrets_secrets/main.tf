resource "kubernetes_manifest" "api_client_credentials" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
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
            key      = "secret/api-client-credentials"
            property = "id"
          },
        },
        {
          secretKey = "secret"
          remoteRef = {
            key      = "secret/api-client-credentials"
            property = "secret"
          }
        }
      ]
      refreshInterval = "5s"
    }
  }
}

resource "kubernetes_manifest" "iskprinter_jwt_keys" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
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
          remoteRef = {
            key      = "secret/iskprinter-jwt-keys"
            property = "private-key"
          }
          secretKey = "private-key.pem"
        },
        {
          remoteRef = {
            key      = "secret/iskprinter-jwt-keys"
            property = "public-key"
          }
          secretKey = "public-key.pem"

        }
      ]
      refreshInterval = "5s"
    }
  }
}
