# bootstrap/variables.tf

variable "cloud_id" {
  type        = string
  default     = "b1g3g3a6ro9rr9hd0mvm"
  description = "Yandex Cloud ID"
}

variable "folder_id" {
  type        = string
  default     = "b1grsjmidldjs2rmkgd0"
  description = "Yandex Cloud Folder ID"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "Availability zone"
}

variable "state_bucket_name" {
  type        = string
  default     = "final-project-tfstate-b1g3g3a6ro9rr9hd0mvm"
  description = "Object Storage bucket for Terraform state"
}

variable "tf_sa_id" {
  type        = string
  description = "Existing tf-terraform service account ID"
}

variable "kms_key_name" {
  type        = string
  default     = "final-project-state"
  description = "KMS key for state bucket encryption"
}
