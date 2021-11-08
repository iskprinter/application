locals {
  neo4j_chart_name = "neo4j"
}

resource "random_password" "neo4j_admin" {
  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

resource "helm_release" "neo4j" {
  name             = var.neo4j_release_name
  chart            = "https://github.com/neo4j-contrib/neo4j-helm/releases/download/${var.neo4j_version}/${local.neo4j_chart_name}-${var.neo4j_version}.tgz"
  version          = var.neo4j_version
  namespace        = var.namespace
  create_namespace = true
  set {
    name  = "acceptLicenseAgreement"
    value = "yes"
  }
  set {
    name  = "core.numberOfServers"
    value = var.neo4j_replicas
  }
  set {
    name  = "core.persistentVolume.size"
    value = var.neo4j_persistent_volume_size
  }
  set {
    name  = "imageTag"
    value = "${var.neo4j_version}-community"
  }
  set_sensitive {
    name  = "neo4jPassword"
    value = random_password.neo4j_admin.result
  }
  set {
    name  = "readReplica.persistentVolume.size"
    value = var.neo4j_persistent_volume_size
  }
}

# Backups

# The replicas are identical, so we only need to back up one
data "kubernetes_persistent_volume_claim" "neo4j" {
  metadata {
    namespace = var.namespace
    name      = "datadir-${local.neo4j_chart_name}-${var.neo4j_release_name}-core-0"
  }
}

# data "kubernetes_persistent_volume" "neo4j" {
#   metadata {
#     namespace = var.namespace
#     name      = "pvc-${data.kubernetes_persistent_volume_claim.metadata[0].uid}"
#   }
# }

# This resource has to be created manually because there is no data.kubernetes_persistent_volume
# resource in Terraform, which is required to associate the PersistentVolume with the GCP volume.
# Refer to https://github.com/hashicorp/terraform-provider-kubernetes/issues/1232
# for the open feature request.

# resource "google_compute_disk_resource_policy_attachment" "neo4j_backup_policy_attachment" {
#   project = var.project
#   zone    = "${var.region}-a"
#   name    = google_compute_resource_policy.backup_policy.name
#   disk    = "pvc-${data.kubernetes_persistent_volume.neo4j.spec.gcePersistentDisk.pdName}"
# }
