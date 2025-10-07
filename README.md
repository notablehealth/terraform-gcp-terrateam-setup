# Terrateam GCP OIDC setup

This bootstraps a workload identity pool for github actions and creates service accounts that the pool can access, with optional restrictions to repositories for all, or per service account.

The service accounts' permissions to modify GCP resources have to be granted elsewhere.
