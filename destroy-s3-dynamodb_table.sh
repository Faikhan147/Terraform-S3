echo "🛠️ Initializing Terraform..."
terraform init -reconfigure

echo "📝 Formatting Terraform files..."
terraform fmt -recursive

echo "🛑 WARNING: This will destroy the s3 and dynamodb_table!"
read -p "Are you absolutely sure? Type 'destroy' to continue: " confirm

if [ "$confirm" == "destroy" ]; then
    echo "🔥 Destroying s3 and dynamodb_table infrastructure..."
    terraform destroy -var-file="terraform.tfvars"

    echo "📊 Showing the current state after destroy..."
    terraform show
else
    echo "❌ Destroy aborted."
fi
