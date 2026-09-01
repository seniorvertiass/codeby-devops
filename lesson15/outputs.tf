output "all_subnets" {
  value = module.subnets.subnets
}

output "vm_id" {
  value = module.vm.vm_id
}

output "vm_name" {
  value = module.vm.vm_name
}

output "selected_subnet_id" {
  value = module.vm.selected_subnet_id
}

output "selected_subnet_name" {
  value = module.vm.selected_subnet_name
}

output "vm_public_ip" {
  value = module.vm.public_ip
}
