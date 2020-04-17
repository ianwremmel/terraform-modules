variable "role" {
  type = string
}

variable "statements" {
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
}
