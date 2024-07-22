output "workload_identity_pool_provider_name" {
  description = "Terrateam provider workload identity pool"
  value       = google_iam_workload_identity_pool_provider.terrateam_provider.name
}
output "service_account_email" {
  description = "Terrateam service account email"
  value       = google_service_account.terrateam.email
}
