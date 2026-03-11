#!/bin/bash
PROJECT_ID=$1
SPACELIFT_HOSTNAME=$2
SPACELIFT_SPACE_ID=$3

if [ -z "$PROJECT_ID" ] || [ -z "$SPACELIFT_HOSTNAME" ] || [ -z "$SPACELIFT_SPACE_ID" ]; then
    echo "Usage: ./setup-spacelift.sh <PROJECT_ID> <SPACELIFT_HOSTNAME> <SPACELIFT_SPACE_ID>"
    echo "Example: ./setup-spacelift.sh my-project my-org.app.spacelift.io space-id"
    exit 1
fi

echo "------------------------------------"
echo "Bootstrapping spacelift for GCP."
echo "------------------------------------"

# 1. Enable APIs
echo "Enabling necessary apis."
gcloud services enable \
    iam.googleapis.com \
    cloudresourcemanager.googleapis.com \
    iamcredentials.googleapis.com \
    sts.googleapis.com \
    --project="${PROJECT_ID}"

# 2. Ensure Runner Service Account exists (Consistent with setup-iam.sh)
sa_name="infra-manager-runner"
sa_email="${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com"

if gcloud iam service-accounts describe "${sa_email}" --project="${PROJECT_ID}" > /dev/null 2>&1; then
    echo "service account \"${sa_email}\" already exists."
else
    echo "Creating service account \"${sa_name}\"."
    gcloud iam service-accounts create "${sa_name}" \
        --display-name="Infrastructure Manager Runner" \
        --project="${PROJECT_ID}"
fi

# 3. Create Workload Identity Pool
pool_id="spacelift-pool"
if gcloud iam workload-identity-pools describe "${pool_id}" --project="${PROJECT_ID}" --location="global" > /dev/null 2>&1; then
    echo "workload identity pool \"${pool_id}\" already exists."
else
    echo "Creating workload identity pool \"${pool_id}\"."
    gcloud iam workload-identity-pools create "${pool_id}" \
        --project="${PROJECT_ID}" \
        --location="global" \
        --display-name="Spacelift Pool"
fi

# 4. Create Workload Identity Provider
provider_id="spacelift-provider"
if gcloud iam workload-identity-pools providers describe "${provider_id}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="${pool_id}" > /dev/null 2>&1; then
    echo "workload identity provider \"${provider_id}\" already exists. Updating."
    gcloud iam workload-identity-pools providers update-oidc "${provider_id}" \
        --project="${PROJECT_ID}" \
        --location="global" \
        --workload-identity-pool="${pool_id}" \
        --attribute-mapping="google.subject=assertion.sub,attribute.space=assertion.spaceId" \
        --attribute-condition="assertion.spaceId == '${SPACELIFT_SPACE_ID}'" \
        --issuer-uri="https://${SPACELIFT_HOSTNAME}" \
        --allowed-audiences="${SPACELIFT_HOSTNAME}"
else
    echo "Creating workload identity provider \"${provider_id}\"."
    gcloud iam workload-identity-pools providers create-oidc "${provider_id}" \
        --project="${PROJECT_ID}" \
        --location="global" \
        --workload-identity-pool="${pool_id}" \
        --display-name="Spacelift Provider" \
        --attribute-mapping="google.subject=assertion.sub,attribute.space=assertion.spaceId" \
        --attribute-condition="assertion.spaceId == '${SPACELIFT_SPACE_ID}'" \
        --issuer-uri="https://${SPACELIFT_HOSTNAME}" \
        --allowed-audiences="${SPACELIFT_HOSTNAME}"
fi

# 5. Grant Service Account impersonation rights
echo "Granting spacelift permission to impersonate the runner service account."
gcloud iam service-accounts add-iam-policy-binding "${sa_email}" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')/locations/global/workloadIdentityPools/${pool_id}/attribute.space/${SPACELIFT_SPACE_ID}" \
    --quiet > /dev/null

# 6. Generate gcp-credentials.json
project_number=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)")
cat <<EOF > gcp-credentials.json
{
  "universe_domain": "googleapis.com",
  "type": "external_account",
  "audience": "//iam.googleapis.com/projects/${project_number}/locations/global/workloadIdentityPools/${pool_id}/providers/${provider_id}",
  "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
  "token_url": "https://sts.googleapis.com/v1/token",
  "credential_source": {
    "file": "/mnt/workspace/spacelift.oidc",
    "format": {
      "type": "text"
    }
  },
  "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${sa_email}:generateAccessToken"
}
EOF

echo "------------------------------------"
echo "SUCCESS: spacelift bootstrap complete."
echo "Generated \"gcp-credentials.json\" for spacelift."
echo "------------------------------------"
echo "Next steps:"
echo "1. Upload \"gcp-credentials.json\" as a mounted file in spacelift."
echo "2. Set \"GOOGLE_APPLICATION_CREDENTIALS\" to the path of the mounted file (e.g., \"/mnt/workspace/gcp-credentials.json\")."
echo "------------------------------------"
