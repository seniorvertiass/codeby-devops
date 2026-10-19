output "cluster_id" {
  value       = yandex_kubernetes_cluster.cluster.id
  description = "Managed Kubernetes cluster ID"
}
output "cluster_name" {
  value       = yandex_kubernetes_cluster.cluster.name
  description = "Managed Kubernetes cluster name"
}
output "registry_id" {
  value       = yandex_container_registry.registry.id
  description = "Yandex Container Registry ID"
}
output "network_id" {
  value       = yandex_vpc_network.network.id
  description = "VPC network ID"
}
