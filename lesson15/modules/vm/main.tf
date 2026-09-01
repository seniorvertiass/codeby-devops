terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.160"
    }
  }
}

locals {
  selected_subnet = [
    for subnet in var.subnets :
    subnet
    if subnet.zone == var.zone
  ][0]
}

resource "yandex_compute_instance" "this" {
  name = var.name
  zone = var.zone

  platform_id = "standard-v3"

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = local.selected_subnet.id
    nat       = var.nat
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key)}"
  }
}
