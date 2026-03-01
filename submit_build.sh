#!/bin/bash
PROJECT_ID=$1
shift # Move past PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: REGION=us-central1 ./submit_build.sh <PROJECT_ID> [--step=<step-id>]"
    exit 1
fi

if [ -z "$REGION" ]; then
    echo "Error: REGION environment variable is not set."
    echo "Usage: REGION=us-central1 ./submit_build.sh <PROJECT_ID> [--step=<step-id>]"
    exit 1
fi

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
echo "Submitting Build for Project: $PROJECT_ID"
echo "Region: $TF_VAR_region"
echo "Only Step: $ONLY_STEP"
echo "------------------------------------"

gcloud beta builds submit . \
    --config=cloudbuild.yaml \
    --substitutions=_REGION="$TF_VAR_region",_ONLY="$ONLY_STEP" \
    "${EXTRA_ARGS[@]}"
