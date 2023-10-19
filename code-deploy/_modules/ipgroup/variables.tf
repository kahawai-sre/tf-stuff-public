variable "name" {
}

variable "resource_group_name" {
}

variable "location" {
}

variable "cidrs" {
    default = null
}

variable "tags" {
  type = map(string)
  default = null
}


