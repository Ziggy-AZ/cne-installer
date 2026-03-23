#!/bin/bash
PROJECT_ID=$1

if [ -z "${PROJECT_ID}" ]; then
    echo "Usage: ./setup-infra-manager.sh <PROJECT_ID>"
    exit 1
fi

sa_name="infra-manager-runner"
sa_email="${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "------------------------------------"
echo "Configuring Infrastructure Manager & Cloud Build."
echo "------------------------------------"

# 1. Enable necessary APIs
gcloud services enable \
    cloudbuild.googleapis.com \
    config.googleapis.com \
    --project="${PROJECT_ID}"

# 2. Ensure Service Identity for Config exists
echo "Ensuring Infrastructure Manager service agent exists."
gcloud beta services identity create \
    --service="config.googleapis.com" \
    --project="${PROJECT_ID}" --quiet > /dev/null 2>&1

# 3. Get Project Details
project_number=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)")
cloud_build_sa="${project_number}@cloudbuild.gserviceaccount.com"

# 4. Grant roles to Infrastructure Manager Service Agent
echo "Configuring service agent impersonation."

# Role on the project
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:service-${project_number}@gcp-sa-config.iam.gserviceaccount.com" \
    --role="roles/config.agent" \
    --quiet > /dev/null

# Role on the Runner GSA
gcloud iam service-accounts add-iam-policy-binding "${sa_email}" \
    --member="serviceAccount:service-${project_number}@gcp-sa-config.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser" \
    --project="${PROJECT_ID}" \
    --quiet > /dev/null

# 5. Cloud Build Permissions
echo "Configuring Cloud Build to manage Infra Manager."

# Role to manage config deployments
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${cloud_build_sa}" \
    --role="roles/config.admin" \
    --quiet > /dev/null

# Role to act as the runner
gcloud iam service-accounts add-iam-policy-binding "${sa_email}" \
    --member="serviceAccount:${cloud_build_sa}" \
    --role="roles/iam.serviceAccountUser" \
    --project="${PROJECT_ID}" \
    --quiet > /dev/null

echo "SUCCESS: Infrastructure Manager IAM complete."
