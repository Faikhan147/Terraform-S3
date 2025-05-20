#!/bin/bash

echo "📁 Step 1: Temporarily disabling backend.tf (if exists)..."
if [ -f backend.tf ]; then
  mv backend.tf backend.tf.disabled
  echo "🔒 backend.tf disabled."
fi

echo "🔍 Step 2: Initializing Terraform locally..."
terraform init

echo "✅ Validating configuration..."
terraform validate

echo "📝 Formatting Terraform files..."
terraform fmt -recursive

echo "📄 Creating plan for S3 and DynamoDB..."
terraform plan -var-file="terraform.tfvars" -out=tfplan.out

echo "⚠️ Review the plan output before applying:"
terraform show tfplan.out

echo "🚀 Do you want to apply this plan to launch S3 and DynamoDB? (yes/no)"
read choice

if [ "$choice" == "yes" ]; then
    echo "✅ Applying changes to launch S3 and DynamoDB..."
    terraform apply "tfplan.out"

    echo "📊 Showing the current state after applying the plan..."
    terraform show

    echo "🔁 Step 3: Enabling backend.tf for remote backend..."
    if [ -f backend.tf.disabled ]; then
        mv backend.tf.disabled backend.tf
        echo "🔓 backend.tf re-enabled."
    fi

    echo "🔧 Step 4: Reinitializing Terraform with remote backend..."
    terraform init -reconfigure
    echo "✅ Remote backend is now configured and state is managed in S3."
else
    echo "❌ Deployment cancelled."
    # Optionally re-enable backend.tf if you want
    if [ -f backend.tf.disabled ]; then
        mv backend.tf.disabled backend.tf
        echo "ℹ️ backend.tf restored."
    fi
fi
