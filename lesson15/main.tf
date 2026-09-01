terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.160"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

module "subnets" {
  source = "./modules/subnets"

  subnet_ids = var.subnet_ids
}

module "vm" {
  source = "./modules/vm"

  name           = var.vm_name
  zone           = var.zone
  subnets        = module.subnets.subnets
  image_id       = var.image_id
  cores          = var.cores
  memory         = var.memory
  disk_size      = var.disk_size
  nat            = var.nat
  ssh_public_key = var.ssh_public_key
}
