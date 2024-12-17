data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_kms_key" "maksys-ct-cmk" {
  provider = aws.ct-management

  key_id = "alias/maksys-ct-encryption-key"
}

locals {
  instance_id = try(aws_instance.maksys_ec2_instance[0].id, "")
  account_id  = data.aws_caller_identity.current.account_id
  aws_region  = data.aws_region.current.name
}

module "schedule" {
  source = "git@github.com:maksystem-platform/terraform-aws-resource-scheduler.git//eventbridge-schedule?ref=v2.2.1"

  count = var.enable_resource_scheduling ? 1 : 0

  providers = {
    aws = aws.ct-management
  }

  schedule_name        = "maksys-ec2-${local.instance_id}-${local.aws_region}-schedule"
  schedule_description = "Account ID: ${local.account_id} | Region: ${local.aws_region} | Instance ID: ${local.instance_id}"
  resource_type        = "ec2"
  resource_schedule    = var.resource_schedule
  kms_key_arn          = data.aws_kms_key.maksys-ct-cmk.arn

  payload = jsonencode({
    start                  = var.resource_schedule.start
    stop                   = var.resource_schedule.stop
    days                   = var.resource_schedule.days
    account_id             = local.account_id
    instance_id            = local.instance_id
    instance_region        = local.aws_region
    instance_default_state = var.instance_default_state
  })
}
