variable "yc_zone" {
  type        = string
  description = "Zone for Yandex Cloud resources"
}

variable "yc_subnet_name" {
  type        = string
  description = "Name of the custom subnet"
}

variable "yc_network_name" {
  type        = string
  description = "Name of the network"
}

variable "yc_route_table_name" {
  type        = string
  description = "Name of the route table"
}

variable "yc_nat_gateway_name" {
  type        = string
  description = "Name of the NAT gateway"
}

variable "yc_security_group_name" {
  type        = string
  description = "Name of the security group"
}

variable "yc_subnet_range" {
  type        = string
  description = "CIDR block for the subnet"
}