#!/bin/bash

echo "=============================="
echo "🌐 Deploying all environments with Terraform Workspaces"
echo "=============================="

# Define environments
environments=("prod" "staging" "qa")

for env in "${environments[@]}"; do
    echo "=============================="
    echo "🌐 Deploying environment: $env"

    BACKEND_FILE="backend-$env.hcl"

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

    # Validate and format
    terraform validate
    terraform fmt -recursive

    # Plan and apply
    PLAN_FILE="tfplan_$env.out"
    terraform plan -out="$PLAN_FILE"
    echo "🚀 Applying plan for $env..."
    terraform apply "$PLAN_FILE"

    echo "✅ Deployment for $env completed!"
done
