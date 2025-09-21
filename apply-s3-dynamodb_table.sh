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

    # Initialize Terraform with backend for this environment
    terraform init -backend-config="$BACKEND_FILE" -reconfigure

    # Validate and format
    terraform validate
    terraform fmt -recursive

    # Create plan
    PLAN_FILE="tfplan_$env.out"
    terraform plan -var-file="$VAR_FILE" -out="$PLAN_FILE"

    # Apply plan
    echo "🚀 Applying plan for $env..."
    terraform apply -var-file="$VAR_FILE" "$PLAN_FILE"

    echo "✅ Deployment for $env completed!"
done
