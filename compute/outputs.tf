# compute/outputs.tf

output "bastion_ip" {
  value = data.terraform_remote_state.infra.outputs.bastion_ip
}

output "alb_ip" {
  value = data.terraform_remote_state.infra.outputs.alb_ip
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
    bastion_ip           = data.terraform_remote_state.infra.outputs.bastion_ip
    ansible_user         = var.ansible_user
    ssh_private_key_path = var.ssh_private_key_path
  })
}
