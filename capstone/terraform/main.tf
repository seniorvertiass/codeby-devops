resource "yandex_vpc_network" "network" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "${var.network_name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = var.subnet_cidr
}

resource "yandex_container_registry" "registry" {
  name      = var.registry_name
  folder_id = var.folder_id
}

resource "yandex_kubernetes_cluster" "cluster" {
  name        = var.cluster_name
  description = "Managed Kubernetes cluster for DevOps CI/CD capstone"
  network_id  = yandex_vpc_network.network.id

  master {
    version = "1.30"
    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.subnet.id
    }
    public_ip = true
    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        day        = "sunday"
        start_time = "03:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.node_service_account_id
  release_channel         = "REGULAR"

  depends_on = [
    yandex_vpc_subnet.subnet
  ]
}

resource "yandex_kubernetes_node_group" "nodes" {
  cluster_id = yandex_kubernetes_cluster.cluster.id
  name       = "capstone-workers"

  instance_template {
    platform_id = "standard-v3"
    resources {
      memory = var.node_memory
      cores  = var.node_cores
    }
    boot_disk {
      type = "network-ssd"
      size = var.node_disk_size
    }
    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.subnet.id]
    }
    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_count
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    maintenance_window {
      day        = "sunday"
      start_time = "03:00"
      duration   = "3h"
    }
  }
}
