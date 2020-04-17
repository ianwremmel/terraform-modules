variable "chambers" {
  type = list(string)
}

variable "enable" {
  default = true
  type    = bool
}

variable "parameter_store_key" {
  default = "alias/parameter_store_key"
}

variable "role" {
  type = string
}
