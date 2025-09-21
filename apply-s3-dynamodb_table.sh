#!/bin/bash
set -e
set -u

VAR_FILE="terraform.tfvars"

echo "🔹 Step 1: Apply S3 bucket and DynamoDB tables locally first..."
terraform init
terraform apply -auto-approve -var-file="$VAR_FILE"

echo "🔹 Step 2: Initialize backend with the created S3 bucket..."
terraform init -backend-config=backend-prod.hcl -reconfigure

echo "🔹 Step 3: Apply again to migrate state to backend..."
terraform apply -auto-approve -var-file="$VAR_FILE"

echo "✅ Deployment completed successfully!"
