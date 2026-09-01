output "subnets" {
  description = "Information about all subnets"

  value = [
    for subnet in data.yandex_vpc_subnet.this : {
      id   = subnet.subnet_id
      name = subnet.name
      zone = subnet.zone
    }
  ]
}
