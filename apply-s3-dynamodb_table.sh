#!/bin/bash
set -e
set -u

VAR_FILE="terraform.tfvars"

echo "🔹 Step 1: Apply S3 bucket and DynamoDB tables locally first (local backend)..."
terraform init -backend=false
terraform apply -auto-approve -var-file="$VAR_FILE"

echo "🔹 Step 2: Initialize S3 backend now that bucket exists..."
terraform init -reconfigure

echo "🔹 Step 3: Migrate state to backend (optional)..."
terraform apply -auto-approve -var-file="$VAR_FILE"

echo "✅ Deployment completed successfully!"
