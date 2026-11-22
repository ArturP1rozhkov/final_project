# bootstrap/providers.tf

terraform {
  required_version = ">= 1.12.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.204.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }

  # bootstrap работает с локальным стейтом, backend "s3" появится в infra и compute
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = pathexpand("~/.yc/authorized_key.json")
}
