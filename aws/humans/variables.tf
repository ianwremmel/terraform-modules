variable "humans" {
  type = list(string)
}

variable "pgp_keys" {
  default     = {}
  description = "Map of username to GPG key for encryption initial password"
}
