#!/bin/bash
set -e
set -u

BACKEND_FILE="backend.tf"
TMP_BACKEND_FILE="backend.tf.bak"

echo "🕒 Temporarily renaming backend.tf to avoid S3 backend errors..."
if [ -f "$BACKEND_FILE" ]; then
    mv "$BACKEND_FILE" "$TMP_BACKEND_FILE"
    echo "✅ backend.tf renamed to $TMP_BACKEND_FILE"
fi

echo "🚀 Applying S3 bucket and DynamoDB tables locally first (local backend)..."
terraform init -backend=false

echo "✅ Validating configuration..."
terraform validate

echo "📝 Formatting Terraform files..."
terraform fmt -recursive

echo "📄 Creating plan..."
terraform plan -var-file="terraform.tfvars" -out=tfplan.out

echo "⚠️ Review the plan output before applying:"
terraform show tfplan.out

echo "🚀 Do you want to apply this plan? (yes/no)"
read choice

if [ "$choice" == "yes" ]; then
    echo "✅ Applying changes..."
    terraform apply "tfplan.out"

    echo "🔄 Restoring backend.tf and initializing S3 backend..."
    if [ -f "$TMP_BACKEND_FILE" ]; then
        mv "$TMP_BACKEND_FILE" "$BACKEND_FILE"
        echo "✅ backend.tf restored"
    fi

    terraform init -reconfigure

    echo "☁️ Migrating state to backend (optional)..."
    terraform apply -var-file="terraform.tfvars"

    echo "🎉 Deployment completed successfully!"
else
    echo "❌ Deployment cancelled by user."
fi
