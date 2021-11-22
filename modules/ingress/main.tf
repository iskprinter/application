data "kubernetes_service" "nginx" {
  metadata {
    namespace = "ingress"
    name      = "ingress-nginx-controller"
  }
}

resource "kubernetes_ingress" "api_iskprinter_com" {
  metadata {
    namespace = var.namespace
    name      = "api-iskprinter-com"
    annotations = {
      "cert-manager.io/cluster-issuer"                    = "lets-encrypt-prod"
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
      host = "api.iskprinter.com"
      http {
        path {
          path = "/"
          backend {
            service_name = var.api_service_name
            service_port = var.api_service_port
          }
        }
      }
    }
    tls {
      hosts       = ["api.iskprinter.com"]
      secret_name = "tls-api-iskprinter-com"
    }
  }
}

resource "kubernetes_ingress" "iskprinter_com" {
  metadata {
    namespace = var.namespace
    name      = "iskprinter-com"
    annotations = {
      "cert-manager.io/cluster-issuer"                    = "lets-encrypt-prod"
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
            service_name = var.frontend_service_name
            service_port = var.frontend_service_port
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
            service_name = var.frontend_service_name
            service_port = var.frontend_service_port
          }
        }
      }
    }
    tls {
      hosts = [
        var.frontend_host,
        "www.${var.frontend_host}"
      ]
      secret_name = "tls-iskprinter-com"
    }
  }
}
