locals {
  mongodb_connection_secret_key_url = "url"
  mongodb_user_admin_username       = "admin"
  mongodb_user_api_username         = "api"
  mongodb_resource_name             = "mongodb"
}

# Secrets

resource "random_password" "mongodb_user_admin_password" {
  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

resource "kubernetes_secret" "mongodb_user_admin_credentials" {
  type = "kubernetes.io/basic-auth"
  metadata {
    namespace = var.namespace
    name      = "mongodb-user-admin-credentials"
  }
  binary_data = {
    username = base64encode(local.mongodb_user_admin_username)
    password = base64encode(random_password.mongodb_user_admin_password.result)
  }
}

resource "random_password" "mongodb_user_api_password" {
  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

resource "kubernetes_secret" "mongodb_user_api_credentials" {
  type = "kubernetes.io/basic-auth"
  metadata {
    namespace = var.namespace
    name      = "mongodb-user-api-credentials"
  }
  binary_data = {
    username = base64encode(local.mongodb_user_api_username)
    password = base64encode(random_password.mongodb_user_api_password.result)
  }
}

# Statefulset

resource "kubectl_manifest" "mongodb" {
  yaml_body = yamlencode({
    apiVersion = "mongodbcommunity.mongodb.com/v1"
    kind       = "MongoDBCommunity"
    metadata = {
      namespace = var.namespace
      name      = local.mongodb_resource_name
      annotations = {
        "userAdminSecretVersion" = kubernetes_secret.mongodb_user_admin_credentials.metadata[0].resource_version
        "userApiSecretVersion"   = kubernetes_secret.mongodb_user_api_credentials.metadata[0].resource_version
      }
    }
    spec = {
      members = var.replica_count
      type    = "ReplicaSet"
      version = "4.2.6"
      security = {
        authentication = {
          modes = ["SCRAM"]
        }
      }
      users = [
        {
          name = local.mongodb_user_admin_username
          db   = "admin"
          passwordSecretRef = { # a reference to the secret that will be used to generate the user's password
            name = kubernetes_secret.mongodb_user_admin_credentials.metadata[0].name
          }
          roles = [
            {
              name = "clusterAdmin"
              db   = "admin"
            },
            {
              name = "userAdminAnyDatabase"
              db   = "admin"
            }
          ]
          scramCredentialsSecretName = local.mongodb_user_admin_username
        },
        {
          name = local.mongodb_user_api_username
          db   = "admin"
          passwordSecretRef = { # a reference to the secret that will be used to generate the user's password
            name = kubernetes_secret.mongodb_user_api_credentials.metadata[0].name
          }
          roles = [
            {
              name = "readWrite"
              db   = "isk-printer"
            }
          ]
          scramCredentialsSecretName = local.mongodb_user_api_username
        }
      ]
      additionalMongodConfig = {
        "storage.wiredTiger.engineConfig.journalCompressor" = "zlib"
      }
      statefulSet = {
        spec = {
          template = {
            spec = {
              containers = [
                {
                  name = "mongodb-agent"
                  resources = {
                    requests = {
                      memory = "400M"
                    }
                    limits = {
                      memory = "500M"
                    }
                  }
                },
                {
                  name = "mongod"
                  resources = {
                    requests = {
                      memory = "400M"
                    }
                    limits = {
                      memory = "500M"
                    }
                  }
                }
              ]
            }
          }
          volumeClaimTemplates = [
            {
              metadata = {
                name = "data-volume"
              }
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.persistent_volume_size
                  }
                }
              }
            }
          ]
        }
      }
    }
  })
}

resource "kubernetes_secret" "mongodb_connection" {
  type = "Opaque"
  metadata {
    namespace = var.namespace
    name      = "mongodb-connection"
  }
  binary_data = {
    (local.mongodb_connection_secret_key_url) = base64encode("mongodb+srv://${urlencode(local.mongodb_user_api_username)}:${urlencode(random_password.mongodb_user_api_password.result)}@${local.mongodb_resource_name}-svc.${var.namespace}.svc.cluster.local/?ssl=false")
  }
}

# Backups

# The replicas are identical, so we only need to back up one
data "kubernetes_persistent_volume_claim" "mongodb" {
  metadata {
    namespace = var.namespace
    name      = "data-volume-${local.mongodb_resource_name}-0"
  }
}

# data "kubernetes_persistent_volume" "mongodb" {
#   metadata {
#     namespace = var.namespace
#     name      = "pvc-${data.kubernetes_persistent_volume_claim.metadata[0].name.uid}"
#   }
# }

# This resource has to be created manually
# because there is no way to access the ID
# of the PV that fulfills the PVC.
# Refer to https://github.com/hashicorp/terraform-provider-kubernetes/issues/1232
# for the open feature request.
# resource "google_compute_disk_resource_policy_attachment" "mongodb_backup_policy_attachment" {

#   project = var.gcp_project
#   zone    = "${var.region}-a"
#   name    = google_compute_resource_policy.backup_policy.name
#   disk    = "pvc-${data.kubernetes_persistent_volume.mongodb.spec.gcePersistentDisk.pdName}"
# }
