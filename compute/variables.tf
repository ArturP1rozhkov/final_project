# compute/variables.tf

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

variable "vm_platform" {
  type        = string
  default     = "standard-v3"
  description = "Compute platform"
}

variable "vm_cores" {
  type        = number
  default     = 2
  description = "vCPU per VM"
}

variable "vm_memory" {
  type        = number
  default     = 8
  description = "RAM per VM, GB"
}

variable "vm_core_fraction" {
  type        = number
  default     = 50
  description = "Guaranteed vCPU share, percent"
}

variable "disk_type" {
  type        = string
  default     = "network-hdd"
  description = "Boot disk type"
}

variable "disk_size" {
  type        = number
  default     = 20
  description = "Boot disk size, GB"
}

variable "preemptible" {
  type        = bool
  default     = true
  description = "Preemptible VMs, switch to false before the defense"
}

variable "ssh_public_key_path" {
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  description = "Public key added to the ansible user"
}

variable "ssh_private_key_path" {
  type        = string
  default     = "~/.ssh/id_k8s"
  description = "Private key for ansible and ssh"
}

variable "ansible_user" {
  type        = string
  default     = "ansible"
  description = "User for ansible and ssh"
}

variable "bastion_name" {
  type        = string
  default     = "final-project-bastion"
  description = "Bastion host and reserved address name"
}

# доступ к стейту infra: те же ключи, что в .backend.hcl
variable "state_bucket" {
  type        = string
  default     = "final-project-tfstate-b1g3g3a6ro9rr9hd0mvm"
  description = "Bucket with Terraform state"
}

variable "state_access_key" {
  type        = string
  sensitive   = true
  description = "Static key for the state bucket"
}

variable "state_secret_key" {
  type        = string
  sensitive   = true
  description = "Static secret for the state bucket"
}
