variable "mx_server_addresses" {
  type = list(object({ name = string, priority = string }))
}

variable "verification_code" {
  default = null
  type    = string
}

variable "ttl" {
  default = "300"
  type    = string
}

variable "zone_id" {
  type = string
}
