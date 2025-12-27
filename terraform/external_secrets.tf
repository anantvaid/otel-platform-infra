resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "1.2.0"
  namespace        = "external-secrets"
  create_namespace = true

  set = [
    {
    name  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = google_service_account.eso_gsa.email
  }]
}