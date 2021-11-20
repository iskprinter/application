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
    replicas = 2
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
          env_from {
            config_map_ref {
              name = "frontend"
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

resource "kubernetes_config_map" "frontend" {
  metadata {
    namespace = var.namespace
    name      = "frontend"
  }
  data = {
    "BACKEND_URL" = "https://api.iskprinter.com"
  }
}
