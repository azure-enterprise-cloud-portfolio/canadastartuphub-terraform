# dev.canadatechintelligence.ca delegation
# NS record in the prod zone pointing to the hosted zone in the dev account (959856141465).
module "dev_delegation" {
  source = "../../modules/route53-delegation"

  parent_zone_name = var.domain
  subdomain        = "dev"
  name_servers     = var.dev_zone_name_servers
}