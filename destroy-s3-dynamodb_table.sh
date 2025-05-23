#!/bin/bash

set -e

echo "🔧 Step 1: Downloading terraform.tfstate from S3..."
aws s3 cp s3://terraform-backend-faisal-khan/s3/terraform.tfstate ./terraform.tfstate

echo "🔧 Step 2: Initializing Terraform locally..."
terraform init -reconfigure

echo "✅ Step 3: Validating Terraform configuration..."
terraform validate

echo "📝 Step 4: Formatting Terraform files..."
terraform fmt -recursive

echo "🔍 Step 5: Showing plan for destroy..."
terraform plan -destroy -var-file="terraform.tfvars"

echo "🛑 WARNING: This will permanently destroy the S3 bucket and DynamoDB table!"
read -p "Type 'destroy' to continue: " confirm

if [ "$confirm" == "destroy" ]; then
    echo "🔥 Destroying S3 and DynamoDB infrastructure..."
    terraform destroy -var-file="terraform.tfvars" -auto-approve

    echo "📊 Showing final Terraform state..."
    terraform show
else
    echo "❌ Destroy aborted by user."
fi

# Optional: Restore backend.tf after destroy
if [ -f backend.tf.disabled ]; then
  mv backend.tf.disabled backend.tf
  echo "🔁 backend.tf restored."
fi
