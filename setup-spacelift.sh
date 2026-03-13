#!/bin/bash
# 0. Clean and Validate Inputs
PROJECT_ID=$(echo "$1" | tr -d '[:space:]')
SPACELIFT_HOSTNAME=$(echo "$2" | tr -d '[:space:]')
SPACELIFT_SPACE_ID=$(echo "$3" | tr -d '[:space:]')
SPACELIFT_SA=$(echo "$4" | tr -d '[:space:]')

if [ -z "$PROJECT_ID" ] || [ -z "$SPACELIFT_HOSTNAME" ] || [ -z "$SPACELIFT_SPACE_ID" ] || [ -z "$SPACELIFT_SA" ]; then
	echo "Usage: ./setup-spacelift.sh <PROJECT_ID> <SPACELIFT_HOSTNAME> <SPACELIFT_SPACE_ID> <SPACELIFT_SA_EMAIL>"
	exit 1
fi

# Validate project existence and get project number early
echo "Validating project: ${PROJECT_ID}..."
project_number=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)" 2>/dev/null)
if [ -z "${project_number}" ]; then
	echo "ERROR: Project \"${PROJECT_ID}\" not found or inaccessible."
	exit 1
fi

echo "------------------------------------"
echo "Bootstrapping Spacelift for GCP Project: ${PROJECT_ID} (#${project_number})"
echo "------------------------------------"

# 1. Enable APIs
echo "Enabling necessary apis."
gcloud services enable \
	cloudresourcemanager.googleapis.com \
	iam.googleapis.com \
	iamcredentials.googleapis.com \
	sts.googleapis.com \
	--project="${PROJECT_ID}"

# 2. Ensure Spacelift Runner Service Account exists
sa_name="spacelift-runner"
sa_email="${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com"

if gcloud iam service-accounts describe "${sa_email}" --project="${PROJECT_ID}" > /dev/null 2>&1; then
	echo "service account \"${sa_email}\" already exists."
else
	echo "Creating service account \"${sa_name}\"."
	gcloud iam service-accounts create "${sa_name}" \
		--display-name="Spacelift Runner" \
		--project="${PROJECT_ID}"
fi

# 3. Grant roles to both the Spacelift Runner and the Spacelift Native SA
resource_roles=(
	"roles/artifactregistry.admin"
	"roles/cloudsql.admin"
	"roles/compute.admin"
	"roles/config.admin"
	"roles/container.admin"
	"roles/iam.serviceAccountAdmin"
	"roles/iam.serviceAccountUser"
	"roles/iam.workloadIdentityPoolAdmin"
	"roles/logging.logWriter"
	"roles/monitoring.metricWriter"
	"roles/resourcemanager.projectIamAdmin"
	"roles/secretmanager.admin"
	"roles/servicenetworking.networksAdmin"
	"roles/serviceusage.serviceUsageAdmin"
	"roles/storage.admin"
)

echo "Ensuring project-level IAM bindings for both identities."
for role in "${resource_roles[@]}"; do
	# 1. Grant to the runner
	if [ -n "${sa_email}" ]; then
		echo "  - Granting ${role} to runner: ${sa_email}."
		gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
			--member="serviceAccount:${sa_email}" \
			--role="${role}" \
			--quiet > /dev/null
	fi
	
	# 2. Grant directly to the Spacelift native identity or WIF principal
	if [ -n "${SPACELIFT_SA}" ]; then
		spacelift_member="${SPACELIFT_SA}"
		# Detect if we need to prefix with serviceAccount:
		if [[ ! "${spacelift_member}" =~ ^(serviceAccount:|user:|group:|domain:|principal:|principalSet:) ]]; then
			spacelift_member="serviceAccount:${spacelift_member}"
		fi
		
		echo "  - Granting ${role} to spacelift: ${spacelift_member}."
		# Removed quiet to allow visibility of the 'does not exist' error if it persists
		gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
			--member="${spacelift_member}" \
			--role="${role}"
	fi
done

# 4. Create Workload Identity Pool
pool_id="spacelift-pool"
if gcloud iam workload-identity-pools describe "${pool_id}" --project="${PROJECT_ID}" --location="global" > /dev/null 2>&1; then
	echo "workload identity pool \"${pool_id}\" already exists."
else
	echo "Creating workload identity pool \"${pool_id}\"."
	gcloud iam workload-identity-pools create "${pool_id}" \
		--display-name="Spacelift Pool" \
		--location="global" \
		--project="${PROJECT_ID}"
fi

# 5. Create Workload Identity Provider
provider_id="spacelift-provider"
if gcloud iam workload-identity-pools providers describe "${provider_id}" \
	--location="global" \
	--project="${PROJECT_ID}" \
	--workload-identity-pool="${pool_id}" > /dev/null 2>&1; then
	echo "workload identity provider \"${provider_id}\" already exists. Updating."
	gcloud iam workload-identity-pools providers update-oidc "${provider_id}" \
		--allowed-audiences="${SPACELIFT_HOSTNAME}" \
		--attribute-condition="assertion.spaceId == '${SPACELIFT_SPACE_ID}'" \
		--attribute-mapping="google.subject=assertion.sub,attribute.space=assertion.spaceId" \
		--issuer-uri="https://${SPACELIFT_HOSTNAME}" \
		--location="global" \
		--project="${PROJECT_ID}" \
		--workload-identity-pool="${pool_id}"
else
	echo "Creating workload identity provider \"${provider_id}\"."
	gcloud iam workload-identity-pools providers create-oidc "${provider_id}" \
		--allowed-audiences="${SPACELIFT_HOSTNAME}" \
		--attribute-condition="assertion.spaceId == '${SPACELIFT_SPACE_ID}'" \
		--attribute-mapping="google.subject=assertion.sub,attribute.space=assertion.spaceId" \
		--display-name="Spacelift Provider" \
		--issuer-uri="https://${SPACELIFT_HOSTNAME}" \
		--location="global" \
		--project="${PROJECT_ID}" \
		--workload-identity-pool="${pool_id}"
fi

# 6. Grant Runner impersonation rights to the WIF principal
echo "Granting WIF principal permission to impersonate the runner."
gcloud iam service-accounts add-iam-policy-binding "${sa_email}" \
	--member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')/locations/global/workloadIdentityPools/${pool_id}/attribute.space/${SPACELIFT_SPACE_ID}" \
	--project="${PROJECT_ID}" \
	--role="roles/iam.workloadIdentityUser" \
	--quiet > /dev/null

# 7. Generate gcp-credentials.json
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
echo "SUCCESS: Spacelift bootstrap complete."
echo "------------------------------------"
echo "Direct permissions granted to: ${SPACELIFT_SA}"
echo "WIF configured for runner: ${sa_email}"
echo "------------------------------------"
