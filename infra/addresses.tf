# infra/addresses.tf

# резервные адреса точек входа: живут дольше вычислительных ресурсов,
# поэтому лежат в infra, а не в compute

resource "yandex_vpc_address" "bastion" {
  name = "final-project-bastion"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_address" "alb" {
  name = "final-project-alb"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}
