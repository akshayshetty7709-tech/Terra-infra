# ------------------------------------------------------------------------------
# Optional root-level backend placeholder.
# In this structure, each environment configures its own backend via
# environments/<env>/backend.tf, passed at init time with:
#   terraform init -backend-config=environments/<env>/backend.tf
# Leave this block empty here so Terraform knows a backend will be supplied
# externally, or delete this file if you configure the backend only per-env.
# ------------------------------------------------------------------------------

terraform {
  backend "s3" {}
}
