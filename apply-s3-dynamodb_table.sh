#!/bin/bash

echo "📂 Step 0: Select environment (prod/staging/qa):"
read env

# Validate input
if [[ "$env" != "prod" && "$env" != "staging" && "$env" != "qa" ]]; then
    echo "❌ Invalid environment. Exiting."
    exit 1
fi

VAR_FILE="terraform.tfvars.$env"
echo "🔹 Using variables file: $VAR_FILE"

echo "📁 Step 1: Temporarily disabling backend.tf (if exists)..."
if [ -f backend.tf ]; then
  mv backend.tf backend.tf.disabled
  echo "🔒 backend.tf disabled."
fi

echo "🔍 Step 2: Initializing Terraform locally..."
terraform init

echo "✅ Step 3: Validating configuration..."
terraform validate

echo "📝 Step 4: Formatting Terraform files..."
terraform fmt -recursive

echo "📄 Step 5: Creating plan for S3 and DynamoDB..."
terraform plan -var-file="$VAR_FILE" -out=tfplan.out

echo "⚠️ Review the plan output before applying:"
terraform show tfplan.out

echo "🚀 Step 6: Apply changes to launch S3 and DynamoDB? (yes/no)"
read choice

if [ "$choice" == "yes" ]; then
    echo "✅ Applying changes to launch S3 and DynamoDB..."
    terraform apply -var-file="$VAR_FILE" "tfplan.out"

    echo "📊 Showing the current state after applying the plan..."
    terraform show

    echo "🔁 Step 7: Enabling backend.tf for remote backend..."
    if [ -f backend.tf.disabled ]; then
        mv backend.tf.disabled backend.tf
        echo "🔓 backend.tf re-enabled."
    fi

    echo "🔧 Step 8: Reinitializing Terraform with remote backend..."
    terraform init -reconfigure -var-file="$VAR_FILE"
    echo "✅ Remote backend is now configured and state is managed in S3."
else
    echo "❌ Deployment cancelled."
    if [ -f backend.tf.disabled ]; then
        mv backend.tf.disabled backend.tf
        echo "ℹ️ backend.tf restored."
    fi
fi
