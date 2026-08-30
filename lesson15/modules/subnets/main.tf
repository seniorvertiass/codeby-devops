terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.160"
    }
  }
}

data "yandex_vpc_subnet" "this" {
  for_each = toset(var.subnet_ids)

  subnet_id = each.value
}
