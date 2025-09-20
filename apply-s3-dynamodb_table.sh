#!/bin/bash

for env in prod staging qa; do
    VAR_FILE="terraform.tfvars.$env"
    echo "🔹 Applying environment: $env using $VAR_FILE"

    # Disable backend.tf temporarily
    if [ -f backend.tf ]; then
        mv backend.tf backend.tf.disabled
    fi

    terraform init
    terraform validate
    terraform fmt -recursive
    terraform plan -var-file="$VAR_FILE" -out=tfplan.out
    terraform apply -var-file="$VAR_FILE" -auto-approve

    # Re-enable backend.tf
    if [ -f backend.tf.disabled ]; then
        mv backend.tf.disabled backend.tf
    fi

    terraform init -reconfigure -var-file="$VAR_FILE"

    echo "✅ Environment $env applied successfully!"
done
