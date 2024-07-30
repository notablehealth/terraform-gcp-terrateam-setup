resource "google_service_account" "terrateam" {
  account_id   = var.service_account_name
  display_name = var.service_account_name
  description  = var.service_account_description
  project      = var.project_id
}

resource "google_iam_workload_identity_pool" "terrateam_pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = var.workload_identity_pool_id
}

resource "google_iam_workload_identity_pool_provider" "terrateam_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.terrateam_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider
  display_name                       = var.workload_identity_provider
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

resource "google_service_account_iam_binding" "terrateam_workload_identity_user" {
  #resource "google_service_account_iam_member" "terrateam_workload_identity_user" {
  service_account_id = google_service_account.terrateam.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/attribute.repository_owner/${var.github_org}"
  ]
}

resource "google_project_iam_member" "terrateam_editor" {
  for_each = { for role in var.service_account_roles : role.role => role }
  project  = var.project_id
  role     = each.value.role
  member   = "serviceAccount:${google_service_account.terrateam.email}"
  dynamic "condition" {
    for_each = each.value.condition != null ? each.value.condition : null
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
