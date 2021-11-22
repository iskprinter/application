data "kubernetes_service" "nginx" {
  metadata {
    namespace = "ingress"
    name      = "ingress-nginx-controller"
  }
}

resource "google_dns_record_set" "api_iskprinter" {
  project      = var.gcp_project
  managed_zone = var.google_dns_managed_zone_name
  name         = "api.iskprinter.com."
  type         = "A"
  rrdatas      = [data.kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip]
  ttl          = 300
}

resource "google_dns_record_set" "iskprinter" {
  project      = var.gcp_project
  managed_zone = var.google_dns_managed_zone_name
  name         = "iskprinter.com."
  type         = "A"
  rrdatas      = [data.kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip]
  ttl          = 300
}

resource "google_dns_record_set" "www_iskprinter" {
  project      = var.gcp_project
  managed_zone = var.google_dns_managed_zone_name
  name         = "www.iskprinter.com."
  type         = "A"
  rrdatas      = [data.kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip]
  ttl          = 300
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
      "nginx.ingress.kubernetes.io/cors-allow-origin"     = "https://iskprinter.com"
      "nginx.ingress.kubernetes.io/enable-cors"           = "true"
    }
  }
  wait_for_load_balancer = true
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
        if ($host ~ "www.iskprinter.com") {
          return 308 "https://iskprinter.com$request_uri";
        }
        EOF
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
