#!/bin/bash
# All-in-one Terraform deploy script for prod, staging, qa
# Handles existing S3 bucket & DynamoDB tables gracefully
# Faisal style

set -e

ENVS=("prod" "staging" "qa")

for ENV in "${ENVS[@]}"; do
    echo "🌟 Initializing Terraform backend for $ENV..."
    BACKEND_FILE="backend-${ENV}.hcl"
    if [[ ! -f "$BACKEND_FILE" ]]; then
        echo "❌ Backend config file $BACKEND_FILE not found!"
        continue
    fi

    terraform init -backend-config="$BACKEND_FILE"

    echo "🚀 Selecting workspace $ENV..."
    terraform workspace select "$ENV" 2>/dev/null || terraform workspace new "$ENV"

    echo "🌟 Importing existing global resources (if any)..."
    # S3 bucket import
    S3_BUCKET=$(grep 'bucket' "$BACKEND_FILE" | awk '{print $3}' | tr -d '"')
    if aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
        terraform import aws_s3_bucket.terraform_backend "$S3_BUCKET" || true
        echo "✅ S3 bucket $S3_BUCKET imported into Terraform state"
    fi

    # DynamoDB tables import
    for TABLE in "terraform-locks-$ENV"; do
        if aws dynamodb describe-table --table-name "$TABLE" 2>/dev/null; then
            terraform import "aws_dynamodb_table.terraform_lock[\"$ENV\"]" "$TABLE" || true
            echo "✅ DynamoDB table $TABLE imported into Terraform state"
        fi
    done

    echo "🚀 Applying resources for $ENV..."
    terraform apply -auto-approve
    echo "✅ Deployment completed for $ENV!"
    echo "------------------------------------------"
done
