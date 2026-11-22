# infra/variables.tf

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

variable "network_name" {
  type        = string
  default     = "final-project-net"
  description = "VPC network name"
}

variable "subnets" {
  type = map(string)
  default = {
    "ru-central1-a" = "10.10.1.0/24"
    "ru-central1-d" = "10.10.3.0/24"
    "ru-central1-e" = "10.10.2.0/24"
  }
  description = "Subnet CIDR per availability zone"
}

variable "admin_cidr" {
  type        = string
  description = "Admin IP allowed to reach the Kubernetes API"
}

variable "registry_name" {
  type        = string
  default     = "final-project-registry"
  description = "Container Registry name"
}
