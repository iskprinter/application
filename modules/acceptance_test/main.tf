locals {
  backoff_limit  = 1
  name           = "acceptance-test"
  restart_policy = "Never"
}

resource "kubernetes_cron_job" "acceptance_test" {
  metadata {
    namespace = var.namespace
    name      = local.name
  }
  spec {
    concurrency_policy = "Replace"
    schedule           = "*/15 * * * *"
    job_template {
      metadata {
        name = local.name
      }
      spec {
        backoff_limit = local.backoff_limit
        template {
          metadata {
            name = local.name
          }
          spec {
            restart_policy = local.restart_policy
            container {
              name  = local.name
              image = var.image
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_job" "acceptance_test" {
  wait_for_completion = true
  metadata {
    namespace = var.namespace
    name      = local.name
  }
  spec {
    backoff_limit = local.backoff_limit
    template {
      metadata {
        name = local.name
      }
      spec {
        restart_policy = local.restart_policy
        container {
          name  = local.name
          image = var.image
        }
      }
    }
  }
}
