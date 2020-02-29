variable "dkim_name" {
  default = null
  type    = string
}

variable "dkim_value" {
  default = null
  type    = string
}

variable "mx_server_addresses" {
  type = list(object({ name = string, priority = string }))
}

variable "ttl" {
  default = "300"
  type    = string
}

variable "verification_code" {
  default = null
  type    = string
}

variable "zone_id" {
  type = string
}
