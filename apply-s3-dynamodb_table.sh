#!/bin/bash

echo "=============================="
echo "🌐 Deploying all environments with multi-DynamoDB support"
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
    
    # Temporarily disable backend.tf if exists
    if [ -f backend.tf ]; then
        mv backend.tf backend.tf.disabled
        echo "🔒 backend.tf disabled."
    fi

    # Initialize Terraform locally
    terraform init -backend-config="$BACKEND_FILE"

    # Validate and format
    terraform validate
    terraform fmt -recursive

    # Create plan
    PLAN_FILE="tfplan_$env.out"
    terraform plan -var-file="$VAR_FILE" -out="$PLAN_FILE"

    # Apply plan
    echo "🚀 Applying plan for $env..."
    terraform apply -var-file="$VAR_FILE" "$PLAN_FILE"

    # Re-enable backend.tf
    if [ -f backend.tf.disabled ]; then
        mv backend.tf.disabled backend.tf
        echo "🔓 backend.tf re-enabled."
    fi

    # Reinitialize with remote backend
    terraform init -reconfigure -backend-config="$BACKEND_FILE" -var-file="$VAR_FILE"
    echo "✅ Deployment for $env completed!"
done
