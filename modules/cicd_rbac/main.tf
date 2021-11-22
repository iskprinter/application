resource "kubernetes_role" "releaser" {
  metadata {
    namespace = var.namespace
    name      = "releaser"
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "get", "patch", "update", "delete"]
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["create", "get", "patch", "update", "delete"]
  }
  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["get"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["create", "get", "patch", "update", "delete"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
    verbs      = ["create", "get", "patch", "update", "delete"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["create", "get", "patch", "update", "delete"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["rolebindings", "roles"]
    verbs      = ["get"]
  }
  rule {
    api_groups = ["mongodbcommunity.mongodb.com"]
    resources  = ["mongodbcommunity"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding" "releasers" {
  metadata {
    namespace = var.namespace
    name      = "releasers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "releaser"
  }
  subject {
    kind      = "ServiceAccount"
    namespace = var.cicd_namespace
    name      = var.cicd_bot_name
  }
}
