locals {
  service_name                             = "api"
  service_port                             = 3000
  api_client_credentials_secret_key_id     = "id"
  api_client_credentials_secret_key_secret = "secret"
}

resource "kubernetes_secret" "api_client_credentials" {
  metadata {
    namespace = var.namespace
    name      = "api-client-credentials"
  }
  data = {
    (local.api_client_credentials_secret_key_id)     = var.api_client_id
    (local.api_client_credentials_secret_key_secret) = var.api_client_secret
  }
}

resource "kubernetes_deployment" "api" {
  metadata {
    namespace = var.namespace
    name      = "api"
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        "app" = "api"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "api"
        }
        annotations = {
          "apiClientCredentialsSecretVersion" = kubernetes_secret.api_client_credentials.metadata[0].resource_version
          "mongodbConnectionSecretVersion"    = var.mongodb_connection_secret_version
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
                name = kubernetes_secret.api_client_credentials.metadata[0].name
                key  = local.api_client_credentials_secret_key_id
              }
            }
          }
          env {
            name = "CLIENT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.api_client_credentials.metadata[0].name
                key  = local.api_client_credentials_secret_key_secret
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
              memory = "256Mi"
            }
            requests = {
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    namespace = var.namespace
    name      = local.service_name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "api"
    }
    port {
      port        = local.service_port
      target_port = local.service_port
    }
  }
}

resource "kubernetes_ingress" "api" {
  wait_for_load_balancer = true
  metadata {
    namespace = var.namespace
    name      = "api"
    annotations = {
      "cert-manager.io/cluster-issuer"                    = "lets-encrypt"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOF
        more_set_input_headers  "strict-transport-security: max-age=63072000; includeSubDomains; preload";
        EOF
      "nginx.ingress.kubernetes.io/cors-allow-origin"     = "https://${var.frontend_host}"
      "nginx.ingress.kubernetes.io/enable-cors"           = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.api_host
      http {
        path {
          path = "/"
          backend {
            service_name = local.service_name
            service_port = local.service_port
          }
        }
      }
    }
    tls {
      hosts       = [var.api_host]
      secret_name = "tls-api"
    }
  }
}
