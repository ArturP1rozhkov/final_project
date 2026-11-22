# infra/outputs.tf

output "network_id" {
  value = yandex_vpc_network.this.id
}

output "subnet_ids" {
  value = { for zone, subnet in yandex_vpc_subnet.this : zone => subnet.id }
}

output "bastion_sg_id" {
  value = yandex_vpc_security_group.bastion.id
}

output "k8s_sg_id" {
  value = yandex_vpc_security_group.k8s.id
}

output "registry_id" {
  value = yandex_container_registry.this.id
}

output "registry_push_url" {
  value = "cr.yandex/${yandex_container_registry.this.id}"
}
