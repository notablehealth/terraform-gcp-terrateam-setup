resource "google_iam_workload_identity_pool" "terrateam_pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = var.workload_identity_pool_id
}
resource "google_iam_workload_identity_pool_provider" "terrateam_provider" {
  project                            = var.project_id
  description                        = var.workload_identity_provider_description
  display_name                       = var.workload_identity_provider
  workload_identity_pool_id          = google_iam_workload_identity_pool.terrateam_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider
  attribute_condition                = "assertion.repository_owner == '${var.github_org}'"
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
locals {
  service_account_repositories = { for svc_acc in var.service_accounts :
    svc_acc.name => length(svc_acc.repositories) > 0 ?
    [for repo in svc_acc.repositories : "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/attribute.repository/${var.github_org}/${repo}"]
    :
    [for repo in var.default_repositories : "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/attribute.repository/${var.github_org}/${repo}"]
  }
}

resource "google_service_account" "terrateam" {
  for_each     = { for svc_acc in var.service_accounts : svc_acc.name => svc_acc }
  account_id   = each.key
  display_name = each.key
  description  = each.value.description
  project      = var.project_id
}

resource "google_service_account_iam_binding" "terrateam_workload_identity_user" {
  for_each           = { for svc_acc in var.service_accounts : svc_acc.name => svc_acc }
  service_account_id = google_service_account.terrateam[each.key].id
  role               = "roles/iam.workloadIdentityUser"
  members            = local.service_account_repositories[each.key]
}
