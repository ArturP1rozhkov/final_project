# compute/alb.tf

# --- 1. Целевая группа ---

resource "yandex_alb_target_group" "nodes" {
  name = "final-project-nodes"

  dynamic "target" {
    for_each = yandex_compute_instance.node
    content {
      subnet_id  = data.terraform_remote_state.infra.outputs.subnet_ids[target.key]
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

# --- 2. Бэкенды ---

resource "yandex_alb_backend_group" "app" {
  name = "final-project-app"

  http_backend {
    name             = "app"
    weight           = 1
    port             = 30080
    target_group_ids = [yandex_alb_target_group.nodes.id]

    healthcheck {
      timeout             = "1s"
      interval            = "2s"
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_healthcheck {
        path = "/healthz"
      }
    }
  }
}

resource "yandex_alb_backend_group" "grafana" {
  name = "final-project-grafana"

  http_backend {
    name             = "grafana"
    weight           = 1
    port             = 30081
    target_group_ids = [yandex_alb_target_group.nodes.id]

    healthcheck {
      timeout             = "1s"
      interval            = "3s"
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_healthcheck {
        path = "/grafana/api/health"
      }
    }
  }
}

# --- 3. Маршрутизация ---

resource "yandex_alb_http_router" "this" {
  name = "final-project-router"
}

resource "yandex_alb_virtual_host" "this" {
  name           = "default"
  http_router_id = yandex_alb_http_router.this.id

  # сначала grafana, иначе её заберёт префикс /
  route {
    name = "grafana"

    http_route {
      http_match {
        path {
          prefix = "/grafana"
        }
      }

      http_route_action {
        backend_group_id = yandex_alb_backend_group.grafana.id
      }
    }
  }

  route {
    name = "app"

    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }

      http_route_action {
        backend_group_id = yandex_alb_backend_group.app.id
      }
    }
  }
}

# --- 4. Балансировщик ---

resource "yandex_alb_load_balancer" "this" {
  name               = "final-project-alb"
  network_id         = data.terraform_remote_state.infra.outputs.network_id
  security_group_ids = [data.terraform_remote_state.infra.outputs.alb_sg_id]

  allocation_policy {
    dynamic "location" {
      for_each = ["ru-central1-a", "ru-central1-d", "ru-central1-e"]
      content {
        zone_id   = location.value
        subnet_id = data.terraform_remote_state.infra.outputs.subnet_ids[location.value]
      }
    }
  }

  listener {
    name = "http"

    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.this.id
      }
    }
  }
}
