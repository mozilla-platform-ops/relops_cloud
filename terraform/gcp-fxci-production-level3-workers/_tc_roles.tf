# This Terraform configuration file's goal is to assign IAM roles to
# Taskcluster service accounts.

# required for worker-manager to be able to do anything in GCP
resource "google_project_iam_member" "worker-manager-compute-admin" {
  project = "fxci-production-level3-workers"
  role    = "roles/compute.admin"
  member  = "serviceAccount:taskcluster-worker-manager@fxci-production-level3-workers.iam.gserviceaccount.com"
}

# TODO:
# - taskcluster-worker@fxci-production-level3-workers.iam.gserviceaccount.com
