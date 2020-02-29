data "aws_route53_zone" "this" {
  zone_id = var.zone_id
}

resource "aws_route53_record" "txt" {
  count = var.type == "TXT" ? 1 : 0

  zone_id = data.aws_route53_zone.this.zone_id

  name = data.aws_route53_zone.this.name
  type = var.type
  ttl  = var.ttl
  records = [
    var.txt_verification_string
  ]
}

resource "aws_route53_record" "cname" {
  count = var.type == "CNAME" ? 1 : 0

  zone_id = data.aws_route53_zone.this.zone_id

  name = var.cname_host
  type = var.type
  ttl  = var.ttl
  records = [
    var.cname_target
  ]
}
