
module "maksys-security-group" {

  count = var.create_sg ? 1 : 0

  source = "git@github.com:maksystem-platform/terraform-aws-security-group.git?ref=v1.0.0"

  vpc_id                  = var.vpc_id
  customer_nwhub_vpc_cidr = var.customer_nwhub_vpc_cidr

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules

  all_tags = merge(
    {
      "Name" = format("%s-%s", var.product, var.name)
    },
    var.all_tags,
  )
}
