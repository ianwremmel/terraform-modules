variable "type" {
  default = "TXT"
  type    = string
}

variable "txt_verification_string" {
  default = null
  type    = string
}

variable "cname_host" {
  default = null
  type    = string
}

variable "cname_target" {
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
