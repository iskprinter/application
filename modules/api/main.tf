locals {
  service_name = "api"
  service_port = 3000
}

resource "kubernetes_service" "api" {
  metadata {
    namespace = var.namespace
    name      = local.service_name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name" = "api"
    }
    port {
      port        = local.service_port
      target_port = local.service_port
    }
  }
}

resource "kubernetes_deployment" "api" {
  metadata {
    namespace = var.namespace
    name      = "api"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "api"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "api"
        }
      }
      spec {
        container {
          name  = "api"
          image = var.image
          env {
            name = "CLIENT_ID"
            value_from {
              secret_key_ref {
                name = var.api_client_credentials_secret_name
                key  = var.api_client_credentials_secret_key_id
              }
            }
          }
          env {
            name = "CLIENT_SECRET"
            value_from {
              secret_key_ref {
                name = var.api_client_credentials_secret_name
                key  = var.api_client_credentials_secret_key_secret
              }
            }
          }
          env {
            name = "DB_URL"
            value_from {
              secret_key_ref {
                name = var.mongodb_connection_secret_name
                key  = var.mongodb_connection_secret_key_url
              }
            }
          }
          port {
            container_port = local.service_port
          }
          liveness_probe {
            http_get {
              port = local.service_port
              path = "/"
            }
          }
          readiness_probe {
            http_get {
              port = local.service_port
              path = "/"
            }
          }
          resources {
            limits = {
              memory = "128Mi"
            }
            requests = {
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}
