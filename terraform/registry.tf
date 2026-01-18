resource "google_project_service" "artifact_registry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "my_repo" {
  location      = var.region
  repository_id = "my-artifact-repo"
  description   = "Docker repository for apps"
  format        = "DOCKER"

  depends_on = [google_project_service.artifact_registry]
}