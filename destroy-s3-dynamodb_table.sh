#!/bin/bash
set -euo pipefail
REGION="us-east-1"

# Backup and cleanup Terraform state
mv backend.tf backend.tf.bak 2>/dev/null || true
rm -rf .terraform .terraform.lock.hcl
mv terraform.tfstate terraform.tfstate.old 2>/dev/null || true
mv terraform.tfstate.backup terraform.tfstate.backup.old 2>/dev/null || true

terraform init -backend=false

bucket="terraform-backend-all-envs"   # apna S3 bucket
tables="terraform-locks-prod terraform-locks-staging terraform-locks-qa terraform-locks-values-prod terraform-locks-values-qa terraform-locks-values-staging"

# Prompt for S3 bucket deletion
read -p "Do you want to delete the S3 bucket '$bucket'? (yes/no): " delete_bucket
if [[ "$delete_bucket" == "yes" ]]; then
    echo "🔹 Deleting all objects and versions in S3 bucket $bucket..."

    if aws s3api head-bucket --bucket "$bucket" --region "$REGION" 2>/dev/null; then
        # Delete all object versions
        versions=$(aws s3api list-object-versions --bucket "$bucket" --region "$REGION" --query 'Versions[].{Key:Key,VersionId:VersionId}' --output text)
        for v in $versions; do
            key=$(echo $v | awk '{print $1}')
            versionId=$(echo $v | awk '{print $2}')
            aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$versionId" --region "$REGION"
        done

        # Delete all delete markers
        markers=$(aws s3api list-object-versions --bucket "$bucket" --region "$REGION" --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output text)
        for m in $markers; do
            key=$(echo $m | awk '{print $1}')
            versionId=$(echo $m | awk '{print $2}')
            aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$versionId" --region "$REGION"
        done

        # Finally delete the bucket
        aws s3 rb "s3://$bucket" --region "$REGION"
        echo "✅ Bucket $bucket deleted successfully!"
    else
        echo "⚠️ Bucket $bucket not found or already deleted"
    fi
else
    echo "⚠️ Skipping S3 bucket deletion"
fi

# Prompt for DynamoDB tables deletion
read -p "Do you want to delete DynamoDB tables? (yes/no): " delete_tables
if [[ "$delete_tables" == "yes" ]]; then
    echo "🔹 Deleting DynamoDB tables..."
    for t in $tables; do
        aws dynamodb delete-table --table-name "$t" --region "$REGION" || echo "Table $t not found"
    done
else
    echo "⚠️ Skipping DynamoDB tables deletion"
fi

echo "✅ Cleanup completed"
