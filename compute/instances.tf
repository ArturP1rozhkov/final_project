# compute/instances.tf

# --- 1. Адрес бастиона ---

resource "yandex_vpc_address" "bastion" {
  name = var.bastion_name

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

# --- 2. Бастион ---

resource "yandex_compute_instance" "bastion" {
  name        = var.bastion_name
  hostname    = var.bastion_name
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-ssd"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = data.terraform_remote_state.infra.outputs.subnet_ids["ru-central1-a"]
    nat                = true
    nat_ip_address     = yandex_vpc_address.bastion.external_ipv4_address[0].address
    security_group_ids = [data.terraform_remote_state.infra.outputs.bastion_sg_id]
  }

  metadata = {
    ssh-keys  = "${var.ansible_user}:${local.ssh_public_key}"
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", { ssh_public_key = local.ssh_public_key, user = var.ansible_user })
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  # чтобы можно было менять метаданные (ключи, cloud-init) без пересоздания
  allow_stopping_for_update = true
}

# --- 3. Мастер ---

resource "yandex_compute_instance" "master" {
  name        = "final-project-master"
  hostname    = "final-project-master"
  platform_id = var.vm_platform
  zone        = "ru-central1-a"

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = var.disk_type
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id          = data.terraform_remote_state.infra.outputs.subnet_ids["ru-central1-a"]
    nat                = false
    security_group_ids = [data.terraform_remote_state.infra.outputs.k8s_sg_id]
  }

  metadata = {
    ssh-keys  = "${var.ansible_user}:${local.ssh_public_key}"
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", { ssh_public_key = local.ssh_public_key, user = var.ansible_user })
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  allow_stopping_for_update = true
}

# --- 4. Ноды ---

resource "yandex_compute_instance" "node" {
  for_each = toset(["ru-central1-d", "ru-central1-e"])

  name        = "final-project-node-${substr(each.key, -1, 1)}"
  hostname    = "final-project-node-${substr(each.key, -1, 1)}"
  platform_id = var.vm_platform
  zone        = each.key

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = var.disk_type
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id          = data.terraform_remote_state.infra.outputs.subnet_ids[each.key]
    nat                = false
    security_group_ids = [data.terraform_remote_state.infra.outputs.k8s_sg_id]
  }

  metadata = {
    ssh-keys  = "${var.ansible_user}:${local.ssh_public_key}"
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", { ssh_public_key = local.ssh_public_key, user = var.ansible_user })
  }

  scheduling_policy {
    preemptible = var.preemptible
  }
}
