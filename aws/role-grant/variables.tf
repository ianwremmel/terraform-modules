variable "enable" {
  default = true
  type    = bool
}

variable "role" {
  description = "Name of the role"
  type        = string
}

variable "policy" {
  default     = null
  description = "A full policy json to apply instead of the statements array. Use this when you need "
  type        = string
}

variable "statements" {
  default     = []
  description = "A list of simply action/resource statements"
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
}
