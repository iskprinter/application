locals {
  port = 80
}

resource "kubernetes_ingress" "frontend" {
  metadata {
    namespace = var.namespace
    name      = "frontend"
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
          path = "/"
          backend {
            service_name = kubernetes_service.frontend.metadata[0].name
            service_port = kubernetes_service.frontend.spec[0].port[0].port
          }
        }
      }
    }
    tls {
      hosts = [
        "iskprinter.com",
        "www.iskprinter.com"
      ]
      secret_name = "tls-iskprinter-com"
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    namespace = var.namespace
    name      = "frontend"
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name" = "frontend"
    }
    port {
      port        = 80
      target_port = kubernetes_deployment.frontend.spec[0].template[0].spec[0].container[0].port[0].container_port
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    namespace = var.namespace
    name      = "frontend"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "frontend"
        }
      }
      spec {
        container {
          name  = "frontend"
          image = var.image
          env_from {
            config_map_ref {
              name = "frontend"
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

resource "kubernetes_config_map" "frontend" {
  metadata {
    namespace = var.namespace
    name      = "frontend"
  }
  data = {
    "BACKEND_URL" = "https://iskprinter.com/${var.api_uri_prefix}"
  }
}
