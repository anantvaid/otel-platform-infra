resource "google_service_account" "eso_gsa" {
  account_id   = "external-secrets-sa"
  display_name = "External Secrets Operator GSA"
}

resource "google_project_iam_member" "eso_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso_gsa.email}"
}

resource "google_service_account_iam_binding" "eso_workload_identity" {
  service_account_id = google_service_account.eso_gsa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/external-secrets]"
  ]
}

resource "google_service_account" "image_updater" {
  account_id   = "image-updater-sa"
  display_name = "ArgoCD Image Updater SA"
}

resource "google_artifact_registry_repository_iam_member" "updater_read" {
  project    = google_artifact_registry_repository.my_repo.project
  location   = google_artifact_registry_repository.my_repo.location
  repository = google_artifact_registry_repository.my_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.image_updater.email}"
}

resource "google_service_account_iam_binding" "updater_wi" {
  service_account_id = google_service_account.image_updater.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[argocd/argocd-image-updater]"
  ]
}