#!/bin/bash

set -e

echo "📂 Step 0: Select environment to destroy (prod/staging/qa):"
read env

# Validate input
if [[ "$env" != "prod" && "$env" != "staging" && "$env" != "qa" ]]; then
    echo "❌ Invalid environment. Exiting."
    exit 1
fi

VAR_FILE="terraform.tfvars.$env"
echo "🔹 Using variables file: $VAR_FILE"

echo "🔧 Step 1: Downloading terraform.tfstate from S3 (optional)..."
aws s3 cp s3://$(grep bucket $VAR_FILE | awk -F'=' '{print $2}' | tr -d ' "')/s3/terraform.tfstate ./terraform.tfstate || echo "ℹ️ No existing state file found locally, continuing..."

echo "🔧 Step 2: Initializing Terraform locally..."
terraform init -reconfigure -var-file="$VAR_FILE"

echo "✅ Step 3: Validating Terraform configuration..."
terraform validate

echo "📝 Step 4: Formatting Terraform files..."
terraform fmt -recursive

echo "🔍 Step 5: Showing plan for destroy..."
terraform plan -destroy -var-file="$VAR_FILE"

echo "🛑 WARNING: This will permanently destroy the S3 bucket and DynamoDB table for '$env'!"
read -p "Type 'destroy' to continue: " confirm

if [ "$confirm" == "destroy" ]; then
    echo "🔥 Destroying S3 and DynamoDB infrastructure..."
    terraform destroy -var-file="$VAR_FILE" -auto-approve

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
