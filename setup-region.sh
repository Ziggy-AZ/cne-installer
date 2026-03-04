#!/bin/bash
PROJECT_ID=$1

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: ./setup-region.sh <PROJECT_ID>"
    exit 1
fi

echo "Fetching available regions."
gcloud compute regions list --project="$PROJECT_ID" --format="value(name)"

read -p "Enter the region name you want to select (default: us-central1): " REGION_NAME
REGION_NAME=${REGION_NAME:-us-central1}

# Set in gcloud config
gcloud config set compute/region "$REGION_NAME" --project="$PROJECT_ID"

# Export for current session
export TF_VAR_region="$REGION_NAME"

# Update terraform.tfvars locally
TFVARS_FILE="terraform.tfvars"
if [ -f "$TFVARS_FILE" ]; then
    # Remove existing entries to avoid duplicates
    sed -i '/project_id/d' "$TFVARS_FILE"
    sed -i '/region/d' "$TFVARS_FILE"
    
    # Append new values
    cat <<EOF >> "$TFVARS_FILE"
project_id   = "$PROJECT_ID"
region       = "$REGION_NAME"
EOF
    echo "------------------------------------"
    echo "SUCCESS: Region set to $REGION_NAME"
    echo "Updated $TFVARS_FILE with automated settings."
    echo "------------------------------------"
    echo "IMPORTANT: Run \"source ./setup-region.sh ${PROJECT_ID}\" to keep the variable in your current shell."
else
    echo "Error: Could not find $TFVARS_FILE"
fi
