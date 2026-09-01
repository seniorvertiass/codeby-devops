variable "token" {
  description = "Yandex Cloud IAM token"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "VM availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "lesson15-vm"
}

variable "image_id" {
  description = "Ubuntu image ID"
  type        = string
}

variable "cores" {
  description = "CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "RAM in GB"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 10
}

variable "nat" {
  description = "Assign public IP"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "SSH public key path"
  type        = string
}
