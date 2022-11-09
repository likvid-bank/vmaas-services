variable "tenant_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "size" {
  type = string
}

variable "source_image_id" {
  type = string
}

variable "username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

# unused
variable "platform_secret" {
  type = string
}

variable "plan_id" {
  type = string
}

variable "plan_name" {
  type = string
}

variable "platform" {
  type = string
}

variable "customer_id" {
  type = string
}

variable "storage" {
  type = number
  default = 0
}
