# compute/data.tf

locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket     = var.state_bucket
    key        = "infra/terraform.tfstate"
    region     = "ru-central1"
    access_key = var.state_access_key
    secret_key = var.state_secret_key

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}
