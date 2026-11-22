# infra/providers.tf

terraform {
  required_version = ">= 1.12.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.204.0"
    }
  }

  # параметры бэкенда передаются файлом: terraform init -backend-config=.backend.hcl
  backend "s3" {}
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = pathexpand("~/.yc/authorized_key.json")
}
