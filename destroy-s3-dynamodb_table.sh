#!/bin/bash

echo "🔒 Step 1: Disabling backend.tf to use local backend..."
if [ -f backend.tf ]; then
  mv backend.tf backend.tf.disabled
  echo "🛠️ backend.tf disabled for local destroy."
fi

echo "🛠️ Step 2: Initializing Terraform..."
terraform init -reconfigure

echo "📝 Formatting Terraform files..."
terraform fmt -recursive

echo "🛑 WARNING: This will destroy the S3 bucket and DynamoDB table!"
read -p "Are you absolutely sure? Type 'destroy' to continue: " confirm

if [ "$confirm" == "destroy" ]; then
    echo "🔥 Destroying S3 and DynamoDB infrastructure..."
    terraform destroy -var-file="terraform.tfvars"

    echo "📊 Showing the state after destruction..."
    terraform show
else
    echo "❌ Destroy aborted by user."
fi

# Optional: Restore backend.tf after destroy
if [ -f backend.tf.disabled ]; then
  mv backend.tf.disabled backend.tf
  echo "🔁 backend.tf restored."
fi
