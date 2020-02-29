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

resource "aws_route53_record" "dkim" {
  count = var.dkim_name == null || var.dkim_value == null ? 0 : 1

  zone_id = data.aws_route53_zone.this.zone_id

  name = var.dkim_name
  type = "TXT"
  ttl  = var.ttl

  records = [
    for dkim_value_chunk in chunklist(split("", var.dkim_value), 255) :
    join("", dkim_value_chunk)
  ]
}
