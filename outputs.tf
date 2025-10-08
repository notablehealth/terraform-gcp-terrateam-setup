output "workload_identity_pool_provider_name" {
  description = "Terrateam provider workload identity pool"
  value       = google_iam_workload_identity_pool_provider.terrateam_provider.name
}

output "service_account_emails" {
  description = "Terrateam service account identifiers"
  value = { for svc_acc in var.service_accounts :
    svc_acc.name => google_service_account.terrateam[svc_acc.name].email
  }
}
