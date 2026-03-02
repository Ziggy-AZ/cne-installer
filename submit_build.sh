#!/bin/bash
PROJECT_ID=$1
shift # Move past PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: ./submit_build.sh <PROJECT_ID> [--step=<step-id>]"
    exit 1
fi

# Attempt to extract region from terraform.tfvars if not provided as an env var
if [ -z "$REGION" ]; then
    if [ -f "terraform.tfvars" ]; then
        REGION=$(grep -E '^[[:space:]]*region[[:space:]]*=' terraform.tfvars | cut -d'=' -f2 | tr -d ' "' | xargs)
    fi
fi

# Default to us-central1 if still not set
REGION=${REGION:-"us-central1"}

# Default to "all"
ONLY_STEP="all"

# Parse remaining arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --step=*)
            ONLY_STEP="${1#*=}"
            shift
            ;;
        *)
            # Collect other args to pass to gcloud
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

TF_VAR_region="$REGION"
gcloud config set project "$PROJECT_ID"

echo "------------------------------------"
echo "Build Started: $(date)"
echo "Submitting Build for Project: $PROJECT_ID"
echo "Region: $TF_VAR_region"
echo "Only Step: $ONLY_STEP"
echo "------------------------------------"

gcloud beta builds submit . \
    --config=cloudbuild.yaml \
    --substitutions=_REGION="$TF_VAR_region",_ONLY="$ONLY_STEP" \
    "${EXTRA_ARGS[@]}"
