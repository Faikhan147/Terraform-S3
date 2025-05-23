#!/bin/bash


echo "📝 Formatting Terraform files..."
terraform fmt -recursive

#!/bin/bash

echo "🛑 WARNING: This will permanently destroy the S3 bucket and DynamoDB table!"
read -p "Type 'destroy' to continue: " confirm

if [ "$confirm" == "destroy" ]; then
    echo "🔥 Destroying S3 and DynamoDB infrastructure..."
    terraform destroy -var-file="terraform.tfvars"

    echo "📊 Showing final state..."
    terraform show
else
    echo "❌ Destroy aborted by user."
fi

# Optional: Restore backend.tf after destroy
if [ -f backend.tf.disabled ]; then
  mv backend.tf.disabled backend.tf
  echo "🔁 backend.tf restored."
fi
