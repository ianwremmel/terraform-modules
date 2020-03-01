variable "admins" {
  default = []
  type    = list(string)
}

variable "enable" {
  default = true
  type    = bool
}

variable "name_prefix" {
  type = string
}

variable "parent_id" {
  type = string
}

variable "root_email_prefix" {
  type = string
}

variable "root_email_domain" {
  type = string
}
