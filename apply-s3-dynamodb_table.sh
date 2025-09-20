#!/bin/bash

ENVS=("prod" "staging" "qa")

for env in "${ENVS[@]}"; do
    VAR_FILE="terraform.tfvars.$env"
    BACKEND_FILE="backend-$env.hcl"

    echo "=============================="
    echo "🌐 Deploying environment: $env"
    echo "Using variables file: $VAR_FILE"
    echo "Using backend file: $BACKEND_FILE"
    echo "=============================="

    # Step 1: Disable backend.tf temporarily
    if [ -f backend.tf ]; then
        mv backend.tf backend.tf.disabled
    fi

    # Step 2: Initialize Terraform with local backend first
    terraform init -reconfigure -backend-config="$BACKEND_FILE"

    # Step 3: Validate & format
    terraform validate
    terraform fmt -recursive

    # Step 4: Create plan
    PLAN_FILE="tfplan_$env.out"
    terraform plan -var-file="$VAR_FILE" -out="$PLAN_FILE"

    # Step 5: Apply plan
    terraform apply -var-file="$VAR_FILE" "$PLAN_FILE"

    # Step 6: Re-enable backend.tf if disabled
    if [ -f backend.tf.disabled ]; then
        mv backend.tf.disabled backend.tf
    fi

    # Step 7: Initialize remote backend
    terraform init -reconfigure -backend-config="$BACKEND_FILE"

    echo "✅ Deployment for $env completed!"
done
