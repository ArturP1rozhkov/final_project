# compute/lb.tf

# --- 1. Целевая группа ---

# ingress-nginx слушает NodePort 30080 на нодах
resource "yandex_lb_target_group" "nodes" {
  name = "final-project-nodes"

  dynamic "target" {
    for_each = yandex_compute_instance.node
    content {
      subnet_id = data.terraform_remote_state.infra.outputs.subnet_ids[target.key]
      address   = target.value.network_interface[0].ip_address
    }
  }
}

# --- 2. Сетевой балансировщик ---

resource "yandex_lb_network_load_balancer" "ingress" {
  name = "final-project-ingress"

  listener {
    name        = "http"
    port        = 80
    target_port = 30080

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.nodes.id

    healthcheck {
      name     = "http"
      interval = 2
      timeout  = 1

      tcp_options {
        port = 30080
      }
    }
  }
}
