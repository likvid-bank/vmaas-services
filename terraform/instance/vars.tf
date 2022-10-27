variable "prefix" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "size" {
  type = string
}

variable "admin" {
  type = object({ username = string, ssh_public_key = string })
}

variable "source_image" {
  type = object({ publisher = string, offer = string, sku = string, version = string })
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "subnet_id" {
  type    = string
}

variable "storage" {
  type    = number
  default = 0
}
