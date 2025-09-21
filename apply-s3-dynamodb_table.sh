#!/bin/bash
set -e
set -u

VAR_FILE="terraform.tfvars"
BACKEND_FILE="backend.tf"
TMP_BACKEND_FILE="backend.tf.bak"

echo "🔹 Step 0: Temporarily rename backend.tf to avoid S3 backend errors..."
if [ -f "$BACKEND_FILE" ]; then
    mv "$BACKEND_FILE" "$TMP_BACKEND_FILE"
    echo "✅ backend.tf renamed to $TMP_BACKEND_FILE"
fi

echo "🔹 Step 1: Apply S3 bucket and DynamoDB tables locally first (local backend)..."
terraform init -backend=false
terraform apply -auto-approve -var-file="$VAR_FILE"

echo "🔹 Step 2: Restore backend.tf and initialize S3 backend..."
if [ -f "$TMP_BACKEND_FILE" ]; then
    mv "$TMP_BACKEND_FILE" "$BACKEND_FILE"
    echo "✅ backend.tf restored"
fi

terraform init -reconfigure

echo "🔹 Step 3: Migrate state to backend (optional)..."
terraform apply -auto-approve -var-file="$VAR_FILE"

echo "✅ Deployment completed successfully!"
