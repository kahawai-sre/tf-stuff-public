

variable "name" {
  description = "Name of the ASG"
}

variable "location" {
  default = "australiaeast"
}

variable "resource_group_name" {
}

variable "tags" {
  type    = map(string)
  default = null
}
