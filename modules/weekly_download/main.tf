resource "kubernetes_cron_job" "weekly_download" {
  metadata {
    namespace = var.namespace
    name      = "weekly-download"
  }
  spec {
    schedule = "3 19 * * 4"
    job_template {
      metadata {
        labels = {
          "app" = "weekly-download"
        }
      }
      spec {
        template {
          metadata {
            name = "weekly-download"
          }
          spec {
            restart_policy = "OnFailure"
            container {
              name  = "weekly-download"
              image = var.image
              env {
                name = "DB_URL"
                value_from {
                  secret_key_ref {
                    name = var.mongodb_connection_secret_name
                    key  = var.mongodb_connection_secret_key_url
                  }
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
  }
}
