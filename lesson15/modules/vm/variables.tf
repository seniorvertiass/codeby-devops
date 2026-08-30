variable "name" {
  type = string
}

variable "zone" {
  type = string
}

variable "subnets" {
  type = list(object({
    id   = string
    name = string
    zone = string
  }))
}

variable "image_id" {
  type = string
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = number
  default = 10
}

variable "nat" {
  type    = bool
  default = true
}

variable "ssh_public_key" {
  type = string
}
