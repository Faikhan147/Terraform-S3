#!/bin/bash
set -e

ENVIRONMENTS=("prod" "staging" "qa")

for ENV in "${ENVIRONMENTS[@]}"; do
    echo "🌐 Initializing Terraform backend for $ENV..."
    terraform init -backend-config="backend-${ENV}.hcl"

    echo "🚀 Applying resources for $ENV..."
    terraform workspace select $ENV 2>/dev/null || terraform workspace new $ENV
    terraform apply -auto-approve

    echo "✅ Deployment completed for $ENV!"
done

echo "🎉 All environments deployed successfully!"
terraform output
