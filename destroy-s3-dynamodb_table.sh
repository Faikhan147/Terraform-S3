#!/bin/bash

set -e

echo "=============================="
echo "🌐 Destroying all environments with Terraform Workspaces"
echo "=============================="

environments=("prod" "staging" "qa")

for env in "${environments[@]}"; do
    echo "=============================="
    echo "🌐 Destroying environment: $env"

    VAR_FILE="terraform.tfvars.$env"
    BACKEND_FILE="backend-$env.hcl"

    # Initialize backend
    terraform init -backend-config="$BACKEND_FILE"

    # Select workspace
    terraform workspace select "$env"
    echo "✅ Selected workspace: $env"

    terraform validate
    terraform fmt -recursive

    echo "🛑 WARNING: This will permanently destroy all resources for '$env'!"
    read -p "Type 'destroy' to continue: " confirm

    if [ "$confirm" == "destroy" ]; then
        terraform destroy -var-file="$VAR_FILE" -auto-approve
        echo "✅ Destroy completed for $env"
    else
        echo "❌ Destroy aborted for $env"
    fi
done
