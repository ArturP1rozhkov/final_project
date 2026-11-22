# infra/network.tf
# проверка terraform pipeline
# --- 1. Сеть ---

resource "yandex_vpc_network" "this" {
  name = var.network_name
}

# --- 2. NAT-шлюз ---

# через него приватные ВМ выходят в интернет за пакетами и образами
resource "yandex_vpc_gateway" "nat" {
  name = "final-project-nat"

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "final-project-private"
  network_id = yandex_vpc_network.this.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

# --- 3. Подсети ---

# по одной в каждой зоне, все приватные: маршрут по умолчанию идёт в NAT-шлюз
resource "yandex_vpc_subnet" "this" {
  for_each = var.subnets

  name           = "${var.network_name}-${substr(each.key, -1, 1)}"
  zone           = each.key
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [each.value]
  route_table_id = yandex_vpc_route_table.private.id
}
