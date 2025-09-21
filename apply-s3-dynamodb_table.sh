#!/bin/bash
set -e  # Exit immediately if a command fails
set -u  # Treat unset variables as error

echo "Initializing Terraform with backend..."
terraform init -backend-config=backend-prod.hcl -reconfigure

echo "Validating Terraform configuration..."
terraform validate

echo "Planning Terraform changes..."
terraform plan -var-file=../terraform.tfvars

echo "Applying Terraform changes..."
terraform apply -auto-approve -var-file=../terraform.tfvars

echo "✅ Deployment completed successfully!"
