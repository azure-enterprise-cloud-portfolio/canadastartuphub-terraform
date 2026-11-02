# dev.canadatechintelligence.ca, delegated from the prod zone with an NS record
module "dev_zone" {
  source = "../../modules/route53-zone"

  zone_name = var.dev_domain
  comment   = "Dev subdomain, delegated from canadatechintelligence.ca (prod account)"
}