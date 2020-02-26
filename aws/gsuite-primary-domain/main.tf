locals {
  all_records = concat(var.mx_server_addresses, [{
    name     = var.verification
    priority = "15"
  }])
}

data "aws_route53_zone" "this" {
  zone_id = var.zone_id
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id

  name = "@"
  type = "MX"
  ttl  = "300"

  records = [
    for address in toset(local.all_records) :
    "${address.priority} ${address.name}"
  ]

}
