resource "aws_route53_zone" "this" {
  name = var.domain_name
}

# The zone originally lived inside the removed amplify-domain module. Re-home
# it in state instead of destroy-and-recreate so the zone (and the nameservers
# delegated at the registrar) survives the module's removal.
moved {
  from = module.amplify_domain.aws_route53_zone.this[0]
  to   = aws_route53_zone.this
}
