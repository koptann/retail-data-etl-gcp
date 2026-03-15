# =============================================================================
# Terraform Backend Configuration - GCS Remote State
# =============================================================================
# This file configures remote state storage in Google Cloud Storage
# 
# Benefits:
# - Team collaboration (shared state)
# - State locking (prevents concurrent modifications)
# - Versioning (state history)
# - Security (encrypted at rest)
#
# Prerequisites:
# 1. Create GCS bucket for state:
#    gcloud storage buckets create gs://YOUR-TF-STATE-BUCKET \
#      --location=EU \
#      --uniform-bucket-level-access
#
# 2. Initialize with backend config:
#    terraform init \
#      -backend-config="bucket=YOUR-TF-STATE-BUCKET" \
#      -backend-config="prefix=terraform/infra"
# =============================================================================

terraform {
  backend "gcs" {
    # Bucket name will be provided via -backend-config during init
    # bucket = "YOUR-TF-STATE-BUCKET"
    
    # Prefix for state file path in bucket
    # prefix = "terraform/infra"
    
    # Enable state locking
    # GCS provides automatic state locking via generation IDs
  }
}

# =============================================================================
# Note: For local development/testing, you can comment out the backend block
# above and Terraform will use local state storage instead.
# =============================================================================
