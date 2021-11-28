locals {
  service_name = "frontend"
  service_port = 80
}

resource "kubernetes_service" "frontend" {
  metadata {
    namespace = var.namespace
    name      = local.service_name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "frontend"
    }
    port {
      port        = local.service_port
      target_port = local.service_port
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    namespace = var.namespace
    name      = "frontend"
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        "app" = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "frontend"
        }
      }
      spec {
        container {
          name  = "frontend"
          image = var.image
          env {
            name = "BACKEND_URL"
            value = "https://${var.api_host}"
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
