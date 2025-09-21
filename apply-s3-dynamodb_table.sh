#!/bin/bash

echo "=============================="
echo "🌐 Deploying all environments with Terraform Workspaces"
echo "=============================="

# Define environments
environments=("prod" "staging" "qa")

for env in "${environments[@]}"; do
    echo "=============================="
    echo "🌐 Deploying environment: $env"

    VAR_FILE="terraform.tfvars.$env"
    BACKEND_FILE="backend-$env.hcl"

    echo "Using variables file: $VAR_FILE"
    echo "Using backend file: $BACKEND_FILE"

    # Initialize Terraform with backend config
    terraform init -backend-config="$BACKEND_FILE"

    # Create or select workspace
    if terraform workspace list | grep -q "$env"; then
        terraform workspace select "$env"
        echo "✅ Selected existing workspace: $env"
    else
        terraform workspace new "$env"
        echo "✅ Created and selected workspace: $env"
    fi

    # Import existing DynamoDB tables (if not already in state)
    echo "🔄 Importing existing DynamoDB tables (if not present)"
    for table in prod staging qa; do
        terraform import -lock=false aws_dynamodb_table.terraform_lock["$table"] "terraform-locks-$table" || true
    done

    # Validate and format
    terraform validate
    terraform fmt -recursive

    # Plan and apply
    PLAN_FILE="tfplan_$env.out"
    terraform plan -var-file="$VAR_FILE" -out="$PLAN_FILE"
    echo "🚀 Applying plan for $env..."
    terraform apply -var-file="$VAR_FILE" "$PLAN_FILE"

    echo "✅ Deployment for $env completed!"
done
