resource "google_service_account" "terrateam" {
  account_id   = var.service_account_name
  display_name = "${var.service_account_name}"
  description  = var.service_account_description
  project      = var.project_id
}

resource "google_iam_workload_identity_pool" "terrateam_pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              ="${var.workload_identity_pool_id}"
}

resource "google_iam_workload_identity_pool_provider" "terrateam_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.terrateam_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider
  display_name                       = "${var.workload_identity_provider}"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_service_account_iam_binding" "terrateam_workload_identity_user" {
  service_account_id = google_service_account.terrateam.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/attribute.repository_owner/${var.github_org}"
  ]
}

resource "google_project_iam_member" "terrateam_editor" {
  project = var.project_id
  role    = var.service_account_role
  member  = "serviceAccount:${google_service_account.terrateam.email}"
}
