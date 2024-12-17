
data "aws_ami" "maksys_ami_lookup" {
  most_recent = var.ami_latest
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = var.ami_name_pattern
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
  }

  filter {
    name   = "root-device-type"
    values = [var.ami_root_device]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virt_type]
  }
}


module "random_ip" {
  source = "./localmodules/random_ip"
  subnet = local.subnet_cidr
}

locals {
  availability_zone = var.availability_zone != "" ? var.availability_zone : element(var.availability_zones, 0)
  subnet_id         = var.subnet_id != "" ? var.subnet_id : element(var.subnet_ids, 0)
  subnet_cidr       = var.subnet_cidr != "" ? var.subnet_cidr : element(var.subnet_cidrs, 0)

  eni_ip = var.eni_ip != "" ? var.eni_ip : var.eni_host != "" ? cidrhost(local.subnet_cidr, var.eni_host) : module.random_ip.random_ip
}

resource "tls_private_key" "maksys_tls_key" {
  count     = var.ec2_key_pair && var.generate_key_pair ? 1 : 0
  algorithm = var.private_key_algorithm
  rsa_bits  = var.private_key_rsa_bits
}

resource "aws_key_pair" "maksys_ec2_key_pair" {
  count = var.ec2_key_pair ? 1 : 0

  key_name        = var.key_name != "" ? var.key_name : null
  key_name_prefix = var.key_name_prefix != "" ? var.key_name_prefix : null
  public_key      = var.generate_key_pair ? trimspace(tls_private_key.maksys_tls_key[0].public_key_openssh) : var.public_key

  tags = var.all_tags
}


resource "aws_network_interface" "maksys_eni" {
  subnet_id       = local.subnet_id
  private_ips     = [local.eni_ip]
  security_groups = length(try(module.maksys-security-group[0].security_group_id, "")) > 0 ? concat(var.additional_sg, tolist([try(module.maksys-security-group[0].security_group_id, "")])) : var.additional_sg
  tags = merge(
    {
      "Name" = "primary_network_interface"
    },
    var.all_tags,
  )
}

#tfsec:ignore:aws-ec2-enable-at-rest-encryption
#tfsec:ignore:aws-ec2-enforce-http-token-imds
resource "aws_instance" "maksys_ec2_instance" {

  count = var.start_instance ? 1 : 0

  ami               = var.ami_id != "" ? var.ami_id : data.aws_ami.maksys_ami_lookup.id
  instance_type     = var.instance_type
  ebs_optimized     = var.ebs_optimized
  availability_zone = local.availability_zone
  subnet_id         = length(var.network_interface) == 0 ? var.subnet_id == "" ? local.subnet_id : var.subnet_id : null
  private_ip        = length(var.network_interface) == 0 ? var.private_ip == "" ? local.eni_ip : var.private_ip : null
  key_name          = try(aws_key_pair.maksys_ec2_key_pair[0].key_name, null)

  monitoring = var.instance_monitoring

  vpc_security_group_ids = length(var.network_interface) == 0 ? concat(var.additional_sg, tolist([module.maksys-security-group[0].security_group_id])) : null

  iam_instance_profile = try(aws_iam_instance_profile.maksys_instance_profile[0].id, null)

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      tags                  = lookup(root_block_device.value, "tags", null)
    }
  }

  #checkov:skip=CKV_AWS_8:Ensure all data stored in the Launch configuration or instance Elastic Blocks Store is securely encrypted
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  #checkov:skip=CKV_AWS_79:Ensure Instance Metadata Service Version 1 is not enabled
  dynamic "metadata_options" {
    for_each = var.metadata_options != {} ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "disabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "optional")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", "1")
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", "disabled")
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = aws_network_interface.maksys_eni.id
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  dynamic "launch_template" {
    for_each = var.launch_template != null ? [var.launch_template] : []
    content {
      id      = lookup(var.launch_template, "id", null)
      name    = lookup(var.launch_template, "name", null)
      version = lookup(var.launch_template, "version", null)
    }
  }

  dynamic "maintenance_options" {
    for_each = length(var.maintenance_options) > 0 ? [var.maintenance_options] : []
    content {
      auto_recovery = try(maintenance_options.value.auto_recovery, null)
    }
  }

  user_data_replace_on_change = var.user_data_replace_on_change
  user_data                   = var.user_data

  tags = merge(
    {
      "Name"                      = format("%s-%s", var.product, var.name)
      "ResourceSchedulingEnabled" = var.enable_resource_scheduling ? "true" : "false"
      git-version                 = var.version_tag
    },
    var.all_tags,
  )
  volume_tags = var.enable_volume_tags ? merge({ "Name" = var.name }, var.volume_tags) : null
}
