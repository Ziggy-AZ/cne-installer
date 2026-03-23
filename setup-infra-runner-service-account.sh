#!/bin/bash
PROJECT_ID=$1

if [ -z "${PROJECT_ID}" ]; then
    echo "Usage: ./setup-infra-runner-service-account.sh <PROJECT_ID>"
    exit 1
fi

sa_name="infra-manager-runner"
sa_email="${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "------------------------------------"
echo "Enabling Core GKE & Gateway APIs."
echo "------------------------------------"

gcloud services enable \
    compute.googleapis.com \
    container.googleapis.com \
    connectgateway.googleapis.com \
    gkehub.googleapis.com \
    iam.googleapis.com \
    iamcredentials.googleapis.com \
    --project="${PROJECT_ID}"

# 1. Check/Create the Service Account
if gcloud iam service-accounts describe "${sa_email}" --project="${PROJECT_ID}" > /dev/null 2>&1; then
    echo "Service Account ${sa_email} already exists."
else
    echo "Creating service account ${sa_name}."
    gcloud iam service-accounts create "${sa_name}" \
        --display-name="Infrastructure Runner" \
        --project="${PROJECT_ID}"
fi

# 2. Grant Core Infrastructure & Gateway Roles
resource_roles=(
    "roles/compute.admin"
    "roles/container.admin"
    "roles/storage.admin"
    "roles/cloudsql.admin"
    "roles/gkehub.admin"
    "roles/gkehub.gatewayAdmin"
    "roles/gkehub.viewer"
    "roles/iam.serviceAccountAdmin"
    "roles/resourcemanager.projectIamAdmin"
    "roles/secretmanager.admin"
    "roles/artifactregistry.admin"
    "roles/logging.logWriter"
    "roles/monitoring.metricWriter"
    "roles/serviceusage.serviceUsageAdmin"
    "roles/iam.workloadIdentityPoolAdmin"
    "roles/servicenetworking.networksAdmin"
    "roles/iam.serviceAccountUser"
)

echo "Ensuring project-level IAM bindings for the runner."
for role in "${resource_roles[@]}"; do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
      --member="serviceAccount:${sa_email}" \
      --role="${role}" \
      --quiet > /dev/null
done

echo "SUCCESS: Infrastructure runner configuration complete."
