resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version
  namespace        = "cert-manager"
  create_namespace = true
  set {
    name  = "installCRDs"
    value = true
  }
  set {
    name  = "prometheus.enabled"
    value = false
  }
  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = "cert-manager@cameronhudson8.iam.gserviceaccount.com"
  }
}

# resource "kubernetes_manifest" "issuer_lets_encrypt_prod" {
resource "kubectl_manifest" "issuer_lets_encrypt_prod" {
  count = var.self_signed ? 0 : 1
  depends_on = [
    helm_release.cert_manager
  ]
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "lets-encrypt"
    }
    spec = {
      acme = {
        # The ACME server URL
        server = "https://acme-v02.api.letsencrypt.org/directory"
        # Email address used for ACME registration
        email = "cameronhudson8@gmail.com"
        # Name of a secret used to store the ACME account private key
        privateKeySecretRef = {
          name = "lets-encrypt-private-key"
        }
        # Enable the DNS-01 challenge provider
        solvers = [
          {
            dns01 = {
              cloudDNS = {
                project = var.project
              }
            }
          }
        ]
      }
    }
  })
}

# resource "kubernetes_manifest" "issuer_lets_encrypt_prod" {
resource "kubectl_manifest" "issuer_lets_encrypt_self_signed" {
  count = var.self_signed ? 1 : 0
  depends_on = [
    helm_release.cert_manager
  ]
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "lets-encrypt"
    }
    spec = {
      selfSigned = {}
    }
  })
}
