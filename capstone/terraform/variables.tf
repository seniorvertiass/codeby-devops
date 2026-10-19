variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}
variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}
variable "zone" {
  description = "Availability zone for subnet and node group"
  type        = string
  default     = "ru-central1-a"
}
variable "network_name" {
  type    = string
  default = "devops-capstone-network"
}
variable "subnet_cidr" {
  type    = list(string)
  default = ["10.20.0.0/24"]
}
variable "registry_name" {
  type    = string
  default = "devops-capstone-registry"
}
variable "cluster_name" {
  type    = string
  default = "devops-capstone-k8s"
}
variable "node_count" {
  type    = number
  default = 2
}
variable "node_cores" {
  type    = number
  default = 2
}
variable "node_memory" {
  type    = number
  default = 4
}
variable "node_disk_size" {
  type    = number
  default = 64
}
variable "service_account_id" {
  description = "Existing service account ID with permissions for Managed Kubernetes and VPC"
  type        = string
}
variable "node_service_account_id" {
  description = "Existing service account ID for Kubernetes nodes"
  type        = string
}
