variable "name" {
}

variable "resource_group_name" {
}

variable "location" {
}

variable "sku" {
    default = null
}

variable "prefix_length" {
    default = null
}

variable "zones" {
    default = null
}

variable "tags" {
  type = map(string)
  default = null
}

