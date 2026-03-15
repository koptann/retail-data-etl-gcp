#!/bin/bash
# =============================================================================
# Bootstrap & Deploy - Retail Data Platform
# =============================================================================
# ⚠️  SECURITY: Replace YOUR_PROJECT_ID with your actual GCP project ID
#     Or set environment variable: export PROJECT_ID="your-project-id"
# =============================================================================

set -e  # Exit on error

# Configuration - REPLACE THESE VALUES OR SET ENVIRONMENT VARIABLES
PROJECT_ID="${PROJECT_ID:-YOUR_PROJECT_ID}"
REGION="${REGION:-europe-west1}"
STATE_BUCKET="${PROJECT_ID}-tfstate"

# Validate configuration
if [ "$PROJECT_ID" = "YOUR_PROJECT_ID" ]; then
    echo "❌ ERROR: Please set your GCP project ID"
    echo ""
    echo "Either:"
    echo "  1. Edit this script and replace YOUR_PROJECT_ID with your project"
    echo "  2. Export environment variable: export PROJECT_ID='your-project-id'"
    echo ""
    exit 1
fi

echo "=========================================="
echo "Bootstrap & Deploy: Retail Data Platform"
echo "=========================================="
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo "State Bucket: gs://$STATE_BUCKET"
echo ""

# =============================================================================
# Step 1: Authenticate
# =============================================================================
echo "Step 1: Authenticating with GCP..."
gcloud auth application-default login
gcloud config set project $PROJECT_ID

# =============================================================================
# Step 2: Create Terraform State Bucket (if it doesn't exist)
# =============================================================================
echo ""
echo "Step 2: Creating Terraform state bucket..."

if gcloud storage buckets describe gs://$STATE_BUCKET &>/dev/null; then
    echo "✓ State bucket already exists: gs://$STATE_BUCKET"
else
    echo "Creating state bucket: gs://$STATE_BUCKET"
    gcloud storage buckets create gs://$STATE_BUCKET \
        --project=$PROJECT_ID \
        --location=EU \
        --uniform-bucket-level-access
    
    echo "Enabling versioning..."
    gcloud storage buckets update gs://$STATE_BUCKET --versioning
    
    echo "✓ State bucket created successfully"
fi

# =============================================================================
# Step 3: Initialize Terraform
# =============================================================================
echo ""
echo "Step 3: Initializing Terraform..."
cd infra/

terraform init \
    -backend-config="bucket=$STATE_BUCKET" \
    -backend-config="prefix=terraform/platform"

echo "✓ Terraform initialized"

# =============================================================================
# Step 4: Validate Configuration
# =============================================================================
echo ""
echo "Step 4: Validating Terraform configuration..."
terraform validate
terraform fmt -recursive
echo "✓ Configuration is valid"

# =============================================================================
# Step 5: Plan Deployment
# =============================================================================
echo ""
echo "Step 5: Generating Terraform plan..."
terraform plan -out=tfplan

echo ""
echo "=========================================="
echo "Bootstrap Complete!"
echo "=========================================="
echo ""
echo "Review the plan above. To deploy, run:"
echo "  cd infra/"
echo "  terraform apply tfplan"
echo ""
echo "Or to skip the plan review:"
echo "  cd infra/"
echo "  terraform apply -auto-approve"
echo ""
