# Look up the existing parent zone (it may be managed outside Terraform).
data "aws_route53_zone" "parent" {
  name         = var.parent_zone_name
  private_zone = false
}

# NS record in the parent zone that delegates <subdomain>.<parent> to the child zone.
resource "aws_route53_record" "delegation" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = "${var.subdomain}.${var.parent_zone_name}"
  type    = "NS"
  ttl     = var.ttl
  records = var.name_servers
}