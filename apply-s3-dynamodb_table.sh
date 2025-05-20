echo "🔍 Initializing Terraform..."
terraform init -reconfigure

echo "✅ Validating configuration..."
terraform validate

echo "📝 Formatting Terraform files..."
terraform fmt -recursive

echo "📄 Creating plan for s3 and dynamodb_table..."
terraform plan -var-file="terraform.tfvars" -out=tfplan.out

echo "⚠️ Review the plan output before applying:"
terraform show tfplan.out

# Fixed the read command syntax
echo "🚀 Do you want to apply this plan to launch s3 and dynamodb_table? (yes/no)"
read choice

if [ "$choice" == "yes" ]; then
    echo "✅ Applying changes to launch s3 and dynamodb_table..."
    terraform apply "tfplan.out"
    
    echo "📊 Showing the current state after applying the plan..."
    terraform show
else
    echo "❌ Deployment cancelled."
fi
