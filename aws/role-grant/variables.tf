variable "enable" {
  default = true
  type    = bool
}

variable "role" {
  type = string
}

variable "statements" {
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
}
