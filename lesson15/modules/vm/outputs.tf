output "vm_id" {
  value = yandex_compute_instance.this.id
}

output "vm_name" {
  value = yandex_compute_instance.this.name
}

output "selected_subnet_id" {
  value = local.selected_subnet.id
}

output "selected_subnet_name" {
  value = local.selected_subnet.name
}

output "public_ip" {
  value = yandex_compute_instance.this.network_interface[0].nat_ip_address
}
