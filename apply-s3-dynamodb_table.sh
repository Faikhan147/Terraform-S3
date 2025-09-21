#!/bin/bash
set -e

echo "🌐 Initializing Terraform..."
terraform init

echo "🚀 Applying S3 Bucket and DynamoDB Tables..."
terraform apply -auto-approve

echo "✅ Deployment completed!"
terraform output
