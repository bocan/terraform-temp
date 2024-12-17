
resource "null_resource" "maksys_get_account_hz" {
  count = var.create_r53_record ? 1 : 0

  provisioner "local-exec" {
    command = "aws route53 list-hosted-zones | jq -r '.name' > ${path.module}/account_phz.txt"
  }
}

data "local_file" "maksys_account_hz" {
  count = var.create_r53_record ? 1 : 0

  filename   = "${path.module}/account_hz.txt"
  depends_on = [null_resource.maksys_get_account_hz[0]]
}

locals {
  account_hz = try(chomp(data.local_file.maksys_account_hz[0].content), "")
}

data "aws_route53_zone" "maksys_zone" {
  count = var.create_r53_record ? 1 : 0

  name         = var.customer_hz != "" ? var.customer_hz : local.account_hz
  private_zone = false
}

resource "aws_route53_record" "maksys_cnamd" {
  #checkov:skip=CKV2_AWS_23:Route53 A Record has Attached Resource

  count = var.start_instance && var.create_r53_record ? 1 : 0

  zone_id = data.aws_route53_zone.maksys_zone[0].zone_id
  name    = "${var.product}.${data.aws_route53_zone.maksys_zone[0].name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.maksys_ec2_instance[0].private_ip]
}
