#!/bin/bash
set -e
set -u

echo "🔹 Initializing Terraform backend..."
terraform init -backend-config=../backend-prod.hcl -reconfigure

echo "🔹 Validating Terraform configuration..."
terraform validate

echo "🔹 Planning Terraform changes..."
terraform plan -var-file=../terraform.tfvars

echo "🔹 Applying Terraform changes..."
terraform apply -auto-approve -var-file=../terraform.tfvars

echo "✅ Deployment completed successfully!"
