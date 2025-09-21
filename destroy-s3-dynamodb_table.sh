#!/bin/bash

set -e

echo "=============================="
echo "🌐 Destroying all environments with multi-DynamoDB support"
echo "=============================="

# Define environments
environments=("prod" "staging" "qa")

for env in "${environments[@]}"; do
    echo "=============================="
    echo "🌐 Destroying environment: $env"
    
    VAR_FILE="terraform.tfvars.$env"
    BACKEND_FILE="backend-$env.hcl"
    
    echo "Using variables file: $VAR_FILE"
    echo "Using backend file: $BACKEND_FILE"

    # Initialize Terraform
    terraform init -reconfigure -backend-config="$BACKEND_FILE" -var-file="$VAR_FILE"

    # Validate and format
    terraform validate
    terraform fmt -recursive

    # Plan destroy
    terraform plan -destroy -var-file="$VAR_FILE"

    echo "🛑 WARNING: This will permanently destroy all DynamoDB tables for '$env'!"
    read -p "Type 'destroy' to continue: " confirm

    if [ "$confirm" == "destroy" ]; then
        terraform destroy -var-file="$VAR_FILE" -auto-approve
        echo "✅ Destroy completed for $env"
    else
        echo "❌ Destroy aborted for $env"
    fi
done
