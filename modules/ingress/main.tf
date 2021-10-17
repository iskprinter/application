resource "kubernetes_ingress" "iskprinter_com" {
  metadata {
    namespace = var.namespace
    name      = "iskprinter-com"
    annotations = {
      "cert-manager.io/cluster-issuer" = "lets-encrypt-prod"
      "nginx.ingress.kubernetes.io/server-snippet" : "if ($host ~ \"www.iskprinter.com\") { return 308 https://iskprinter.com$request_uri; }"
    }
  }
  wait_for_load_balancer = true
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "iskprinter.com"
      http {
        path {
          path = "/"
          backend {
            service_name = var.frontend_service_name
            service_port = var.frontend_service_port
          }
        }
        path {
          path = "/${var.api_uri_prefix}"
          backend {
            service_name = var.api_service_name
            service_port = var.api_service_port
          }
        }
      }
    }
    rule {
      host = "www.iskprinter.com"
      http {
        path {
          path = "/"
          backend {
            service_name = var.frontend_service_name
            service_port = var.frontend_service_port
          }
        }
        path {
          path = "/${var.api_uri_prefix}"
          backend {
            service_name = var.api_service_name
            service_port = var.api_service_port
          }
        }
      }
    }
    tls {
      hosts       = [
        "iskprinter.com",
        "www.iskprinter.com"
      ]
      secret_name = "tls-iskprinter-com"
    }
  }
}
