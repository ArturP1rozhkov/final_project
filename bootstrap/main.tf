# bootstrap/main.tf

# --- 1. Роли tf-terraform ---

# сам аккаунт создан вручную (см. README), здесь только привязки
# первые три нужны самому bootstrap: ими он создаёт аккаунты, бакет и ключ KMS
locals {
  tf_roles = toset([
    "iam.serviceAccounts.admin",
    "storage.admin",
    "kms.admin",
    "iam.serviceAccounts.user",
    "vpc.admin",
    "compute.admin",
    "k8s.admin",
    "container-registry.admin",
    "load-balancer.admin",
    "alb.admin",
  ])
}

resource "yandex_resourcemanager_folder_iam_member" "tf_terraform" {
  for_each  = local.tf_roles
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${var.tf_sa_id}"
}

# --- 2. Сервисный аккаунт для S3-бэкенда ---

resource "yandex_iam_service_account" "tf_backend" {
  name        = "tf-backend"
  description = "Terraform state backend"
  folder_id   = var.folder_id
}

resource "yandex_iam_service_account_static_access_key" "tf_backend" {
  service_account_id = yandex_iam_service_account.tf_backend.id
  description        = "terraform backend"
}

# --- 3. KMS ---

resource "yandex_kms_symmetric_key" "state" {
  name              = var.kms_key_name
  description       = "Terraform state bucket encryption"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}

# ключ нужен tf-backend для записи стейта в бакет
resource "yandex_kms_symmetric_key_iam_binding" "encrypters" {
  symmetric_key_id = yandex_kms_symmetric_key.state.id
  role             = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${yandex_iam_service_account.tf_backend.id}",
  ]
}

# --- 4. Бакет со стейтами ---

resource "yandex_storage_bucket" "state" {
  bucket    = var.state_bucket_name
  folder_id = var.folder_id

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = yandex_kms_symmetric_key.state.id
      }
    }
  }

  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }
}

# storage.editor только на этот бакет, на каталог роли нет
resource "yandex_storage_bucket_iam_binding" "tf_backend" {
  bucket = yandex_storage_bucket.state.bucket
  role   = "storage.editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.tf_backend.id}",
  ]
}
