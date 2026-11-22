# compute/outputs.tf

output "bastion_ip" {
  value = yandex_vpc_address.bastion.external_ipv4_address[0].address
}

output "alb_ip" {
  value = yandex_alb_load_balancer.this.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "alb_router_id" {
  value = yandex_alb_http_router.this.id
}

output "master_ip" {
  value = yandex_compute_instance.master.network_interface[0].ip_address
}

output "node_ips" {
  value = {
    node-d = yandex_compute_instance.node["ru-central1-d"].network_interface[0].ip_address
    node-e = yandex_compute_instance.node["ru-central1-e"].network_interface[0].ip_address
  }
}

output "ansible_user" {
  value = var.ansible_user
}

output "ssh_private_key_path" {
  value = var.ssh_private_key_path
}

output "ssh_config" {
  value = templatefile("${path.module}/ssh_config.tpl", {
    bastion_ip           = yandex_vpc_address.bastion.external_ipv4_address[0].address
    ansible_user         = var.ansible_user
    ssh_private_key_path = var.ssh_private_key_path
  })
}
