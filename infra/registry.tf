# infra/registry.tf

# --- 1. Container Registry ---

resource "yandex_container_registry" "this" {
  name      = var.registry_name
  folder_id = var.folder_id
}
