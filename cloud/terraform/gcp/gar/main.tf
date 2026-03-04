# 0. Enable KMS API
resource "google_project_service" "kms" {
	count=var.create_kms_key ? 1 : 0
	project=var.project_id
	service="cloudkms.googleapis.com"

	disable_on_destroy=false
}

# 1. (Optional) Create KMS Keyring and Key
resource "google_kms_key_ring" "this" {
	count=var.create_kms_key ? 1 : 0
	name="${var.deployment_name}-gar-keyring"
	location=var.region
	project=var.project_id

	depends_on=[google_project_service.kms]
}

resource "google_kms_crypto_key" "this" {
	count=var.create_kms_key ? 1 : 0
	name="${var.deployment_name}-gar-key"
	key_ring=google_kms_key_ring.this[0].id
	rotation_period="7776000s" # 90 days

	lifecycle {
		prevent_destroy=true
	}
}

# 2. Get the Artifact Registry Service Agent
resource "google_project_service_identity" "gar_sa" {
	count=var.create_kms_key ? 1 : 0
	provider=google-beta
	project=var.project_id
	service="artifactregistry.googleapis.com"
}

# 3. Grant the Service Agent permission to use the KMS key
resource "google_kms_crypto_key_iam_member" "gar_kms" {
	count=var.create_kms_key ? 1 : 0
	crypto_key_id=google_kms_crypto_key.this[0].id
	role="roles/cloudkms.cryptoKeyEncrypterDecrypter"
	member="serviceAccount:${google_project_service_identity.gar_sa[0].email}"
}

# 4. Create the Artifact Registry Repository
resource "google_artifact_registry_repository" "this" {
	location=var.region
	repository_id="${var.deployment_name}-registry"
	description="Docker registry for ${var.deployment_name} images"
	format="DOCKER"
	kms_key_name=var.create_kms_key ? google_kms_crypto_key.this[0].id : var.kms_key_name

	docker_config {
		immutable_tags =true
	}

	cleanup_policy_dry_run=false

	# Keep the most recent 10 versions of each image
	cleanup_policies {
		id="keep-latest-versions"
		action="KEEP"
		most_recent_versions {
			keep_count=10
		}
	}

	# Delete versions older than 30 days
	cleanup_policies {
		id="delete-old-versions"
		action="DELETE"
		condition {
			older_than="2592000s" # 30 days in seconds
		}
	}
}

# 5. Make the repository public (Optional)
resource "google_artifact_registry_repository_iam_member" "public_viewer" {
	count=var.enable_public_gar_access ? 1 : 0
	project=google_artifact_registry_repository.this.project
	location=google_artifact_registry_repository.this.location
	repository=google_artifact_registry_repository.this.name
	role="roles/artifactregistry.reader"
	member="allUsers"
}