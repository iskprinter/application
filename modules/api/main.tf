locals {
  port = 3000
}

resource "kubernetes_ingress" "api" {
  metadata {
    namespace = var.namespace
    name      = "api"
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }
  spec {
    rule {
      host = "iskprinter.com"
      http {
        path {
          path = "/${var.api_uri_prefix}"
          backend {
            service_name = kubernetes_service.api.metadata[0].name
            service_port = kubernetes_service.api.spec[0].port[0].port
          }
        }
      }
    }
    rule {
      host = "www.iskprinter.com"
      http {
        path {
          path = "/${var.api_uri_prefix}"
          backend {
            service_name = kubernetes_service.api.metadata[0].name
            service_port = kubernetes_service.api.spec[0].port[0].port
          }
        }
      }
    }
    tls {
      hosts = ["iskprinter.com"]
      secret_name = "tls-iskprinter-com"
    }
    tls {
      hosts = ["www.iskprinter.com"]
      secret_name = "tls-www-iskprinter-com"
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    namespace = var.namespace
    name      = "api"
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name" = "api"
    }
    port {
      port        = 80
      target_port = kubernetes_deployment.api.spec[0].template[0].spec[0].container[0].port[0].container_port
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
            container_port = local.port
          }
          liveness_probe {
            http_get {
              port = local.port
              path = "/"
            }
          }
          readiness_probe {
            http_get {
              port = local.port
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
