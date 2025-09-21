#!/bin/bash
set -e
set -u

VAR_FILE="terraform.tfvars"

echo "🔹 Step 1: Initialize Terraform and apply resources..."
terraform init -reconfigure
terraform apply -auto-approve -var-file="$VAR_FILE"

echo "✅ Deployment completed successfully!"
