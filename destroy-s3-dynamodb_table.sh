#!/bin/bash

set -e

ENVS=("prod" "staging" "qa")

for env in "${ENVS[@]}"; do
    VAR_FILE="terraform.tfvars.$env"
    BACKEND_FILE="backend-$env.hcl"

    echo "=============================="
    echo "⚠️ Destroying environment: $env"
    echo "Using variables file: $VAR_FILE"
    echo "Using backend file: $BACKEND_FILE"
    echo "=============================="

    # Step 1: Disable backend.tf temporarily
    if [ -f backend.tf ]; then
        mv backend.tf backend.tf.disabled
    fi

    # Step 2: Initialize Terraform
    terraform init -reconfigure -backend-config="$BACKEND_FILE"

    # Step 3: Validate & format
    terraform validate
    terraform fmt -recursive

    # Step 4: Plan destroy
    terraform plan -destroy -var-file="$VAR_FILE"

    # Step 5: Confirm destroy
    read -p "Type 'destroy' to actually destroy $env: " confirm
    if [ "$confirm" == "destroy" ]; then
        terraform destroy -var-file="$VAR_FILE" -auto-approve
        echo "✅ Destroyed $env successfully!"
    else
        echo "❌ Destroy aborted for $env."
    fi

    # Step 6: Re-enable backend.tf if disabled
    if [ -f backend.tf.disabled ]; then
        mv backend.tf.disabled backend.tf
    fi

done
