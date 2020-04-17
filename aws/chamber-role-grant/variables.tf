variable "chambers" {
  type = list(string)
}

variable "parameter_store_key" {
  default = "alias/parameter_store_key"
}

variable "role" {
  type = string
}
