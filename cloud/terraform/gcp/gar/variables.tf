variable "deployment_name" {
  default = "liferay-self-hosted"
}

variable "region" {
  type = string
}

variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "kms_key_name" {
  description = "The Cloud KMS key name to encrypt the repository. If not provided and create_kms_key is false, Google-managed keys will be used."
  type        = string
  default     = null
}

variable "create_kms_key" {
  description = "Whether to create a new Cloud KMS key for the repository. If true, kms_key_name will be ignored."
  type        = bool
  default     = false
}

variable "enable_public_gar_access" {
  description = "Whether to make the Artifact Registry repository public (allUsers)."
  type        = bool
  default     = false
}