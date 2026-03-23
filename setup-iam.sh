#!/bin/bash
PROJECT_ID=$1

if [ -z "${PROJECT_ID}" ]; then
    echo "Usage: ./setup-iam.sh <PROJECT_ID>"
    exit 1
fi

sa_name="infra-manager-runner"
sa_email="${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "------------------------------------"
echo "Configuring IAM for Infrastructure Manager."
echo "------------------------------------"

# 1. Check/Create the Service Account
if gcloud iam service-accounts describe "${sa_email}" --project="${PROJECT_ID}" > /dev/null 2>&1; then
    echo "Service Account ${sa_email} already exists. Skipping creation."
else
    echo "Creating service account ${sa_name}."
    gcloud iam service-accounts create "${sa_name}" \
        --display-name="Infrastructure Manager Runner" \
        --project="${PROJECT_ID}"
fi

# 2. Grant the Service Account specific admin roles (Least Privilege)
resource_roles=(
    "roles/compute.admin" 
    "roles/container.admin" 
    "roles/storage.admin" 
    "roles/cloudsql.admin" 
    "roles/iam.serviceAccountAdmin" 
    "roles/resourcemanager.projectIamAdmin"
    "roles/secretmanager.admin"
    "roles/artifactregistry.admin"
    "roles/logging.logWriter"
    "roles/monitoring.metricWriter"
    "roles/serviceusage.serviceUsageAdmin"
    "roles/iam.workloadIdentityPoolAdmin"
    "roles/config.admin"
    "roles/servicenetworking.networksAdmin"
    "roles/iam.serviceAccountUser"
)

echo "Ensuring project-level IAM bindings."
for role in "${resource_roles[@]}"; do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
      --member="serviceAccount:${sa_email}" \
      --role="${role}" \
      --quiet > /dev/null
done

# 3. Get the Project Number
project_number=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)")

# 4. Grant Infra Manager Service Agent permissions
echo "Configuring Infrastructure Manager service agent."
# The Service Agent needs this role on the project to manage deployments
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:service-${project_number}@gcp-sa-config.iam.gserviceaccount.com" \
    --role="roles/config.agent" \
    --quiet > /dev/null

# CRITICAL: The Service Agent must be able to "act as" the Runner Service Account
gcloud iam service-accounts add-iam-policy-binding "${sa_email}" \
    --member="serviceAccount:service-${project_number}@gcp-sa-config.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser" \
    --project="${PROJECT_ID}" \
    --quiet > /dev/null

cloud_build_sa="${project_number}@cloudbuild.gserviceaccount.com"

echo "Granting Cloud Build service account permissions to manage Infra Manager."

# Grant Cloud Build the ability to create and manage deployments
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${cloud_build_sa}" \
    --role="roles/config.admin" \
    --quiet > /dev/null

# Grant Cloud Build permission to "act as" the Runner Service Account
echo "Granting Cloud Build permission to act as the runner."
gcloud iam service-accounts add-iam-policy-binding "${sa_email}" \
    --member="serviceAccount:${cloud_build_sa}" \
    --role="roles/iam.serviceAccountUser" \
    --project="${PROJECT_ID}" \
    --quiet > /dev/null

# 5. Grant Crossplane IAM GSA necessary roles
local cp_iam_gsa="liferay-deployment-cp-iam@${PROJECT_ID}.iam.gserviceaccount.com"
local cp_roles=(
    "roles/compute.admin"
    "roles/cloudsql.admin"
    "roles/storage.admin"
    "roles/iam.serviceAccountAdmin"
    "roles/resourcemanager.projectIamAdmin"
)

echo "Ensuring Crossplane IAM GSA bindings."
for role in "${cp_roles[@]}"; do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
      --member="serviceAccount:${cp_iam_gsa}" \
      --role="${role}" \
      --quiet > /dev/null
done

echo "SUCCESS: IAM configuration complete."
