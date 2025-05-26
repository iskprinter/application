resource "kubernetes_config_map" "data_downloader" {
  metadata {
    name      = "data-downloader"
    namespace = var.namespace
  }
  data = {
    "__main__.py"      = file("${path.module}/src/__main__.py")
    "requirements.txt" = file("${path.module}/src/requirements.txt")
    "run.sh"           = file("${path.module}/src/run.sh")
  }
}

locals {
  volume_name = "data-downloader"
}
resource "kubernetes_cron_job_v1" "data_downloader" {
  metadata {
    name      = "data-downloader"
    namespace = var.namespace
  }
  spec {
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            container {
              command = [
                "/usr/bin/env",
                "bash",
                "/app/src/run.sh",
                "/app"
              ]
              image = "registry.hub.docker.com/library/python:3"
              name  = "data-downloader"
              volume_mount {
                name       = local.volume_name
                mount_path = "/app/src"
              }
            }
            volume {
              name = local.volume_name
              config_map {
                name = kubernetes_config_map.data_downloader.metadata[0].name
              }
            }
          }
        }
      }
    }
    # minute hour day week month
    schedule = "18 11 * * *"
  }
}
