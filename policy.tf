data "aws_partition" "current" {}

locals {
  iam_role_name = try(coalesce(var.iam_role_name, var.name), "")
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create_iam_instance_profile ? 1 : 0

  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "maksys_instance_role" {
  count = var.create_iam_instance_profile ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.all_tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "maksys_role_policy" {
  for_each = { for k, v in var.iam_role_policies : k => v if var.create_iam_instance_profile }

  policy_arn = each.value
  role       = aws_iam_role.maksys_instance_role[0].name
}

resource "aws_iam_instance_profile" "maksys_instance_profile" {
  count = var.create_iam_instance_profile ? 1 : 0

  role = aws_iam_role.maksys_instance_role[0].name

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path

  tags = merge(var.all_tags, var.iam_role_tags)

  lifecycle {
    create_before_destroy = true
  }
}
