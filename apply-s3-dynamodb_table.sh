#!/bin/bash
set -e

# Check for argument
if [ -z "$1" ]; then
    echo "🌐 Deploying all environments..."
    ENVS=("prod" "staging" "qa")
else
    ENVS=("$1")
fi

for ENV in "${ENVS[@]}"; do
    echo "🌐 Initializing Terraform backend for $ENV..."
    terraform init -backend-config="backend-${ENV}.hcl"

    echo "🚀 Selecting workspace $ENV..."
    terraform workspace select $ENV 2>/dev/null || terraform workspace new $ENV

    echo "🌟 Importing existing global resources (if not already in state)..."
    # S3 Bucket
    terraform import -ignore-remote-version aws_s3_bucket.terraform_backend terraform-backend-all-env 2>/dev/null || true
    # DynamoDB Tables
    for TBL in prod staging qa; do
        terraform import -ignore-remote-version aws_dynamodb_table.terraform_lock["$TBL"] terraform-locks-$TBL 2>/dev/null || true
    done

    echo "🚀 Applying resources for $ENV..."
    terraform plan -out=tfplan_$ENV.out
    terraform apply -auto-approve tfplan_$ENV.out

    echo "✅ Deployment completed for $ENV!"
done

echo "🎉 All environments deployed successfully!"
