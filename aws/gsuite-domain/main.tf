locals {
  all_records = var.verification_code == null ? var.mx_server_addresses : concat(var.mx_server_addresses, [{
    name     = var.verification_code
    priority = "15"
  }])
}

data "aws_route53_zone" "this" {
  zone_id = var.zone_id
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id

  name = data.aws_route53_zone.this.name
  type = "MX"
  ttl  = var.ttl

  records = [
    for address in toset(local.all_records) :
    "${address.priority} ${address.name}"
  ]
}
