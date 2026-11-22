# compute/outputs.tf

output "bastion_ip" {
  value = yandex_vpc_address.bastion.external_ipv4_address[0].address
}

output "lb_ip" {
  value = one(flatten([for listener in yandex_lb_network_load_balancer.ingress.listener : listener.external_address_spec[*].address]))
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
