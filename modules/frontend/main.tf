locals {
  service_name = "frontend"
  service_port = 80
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
            name  = "BACKEND_URL"
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

resource "kubernetes_ingress" "frontend" {
  count                  = var.create_ingress ? 1 : 0
  wait_for_load_balancer = true
  metadata {
    namespace = var.namespace
    name      = "frontend"
    annotations = {
      "cert-manager.io/cluster-issuer"                    = var.cert_manager_issuer_name
      "nginx.ingress.kubernetes.io/configuration-snippet" = "more_set_input_headers \"strict-transport-security: max-age=63072000; includeSubDomains; preload\";"
      "nginx.ingress.kubernetes.io/server-snippet"        = <<-EOF
        if ($host ~ "www.${var.frontend_host}") {
          return 308 "https://${var.frontend_host}$request_uri";
        }
        EOF
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.frontend_host
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
    rule {
      host = "www.${var.frontend_host}"
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
      hosts = [
        var.frontend_host,
        "www.${var.frontend_host}"
      ]
      secret_name = "tls-frontend"
    }
  }
}
