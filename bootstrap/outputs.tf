# bootstrap/outputs.tf

output "sa_cluster_id" {
  value = yandex_iam_service_account.k8s_cluster.id
}

output "sa_nodes_id" {
  value = yandex_iam_service_account.k8s_nodes.id
}

output "bucket" {
  value = yandex_storage_bucket.state.bucket
}

output "access_key" {
  value = yandex_iam_service_account_static_access_key.tf_backend.access_key
}

output "secret_key" {
  value     = yandex_iam_service_account_static_access_key.tf_backend.secret_key
  sensitive = true
}

output "kms_key_id" {
  value = yandex_kms_symmetric_key.state.id
}
