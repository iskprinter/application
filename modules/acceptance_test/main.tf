resource "kubernetes_cron_job" "acceptance_test" {
  metadata {
    namespace = var.namespace
    name      = "acceptance-test"
  }
  spec {
    concurrency_policy = "Replace"
    schedule           = "*/15 * * * *"
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {
            name      = "acceptance-test"
          }
          spec {
            container {
              name    = "acceptance-test"
              image   = var.image
            }
          }
        }
      }
    }
  }
}
