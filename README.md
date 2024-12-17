# Overview

This module contains components for creating EC2 instances with some switchable optional resources

NOTE:  This module has taken significant parts from [terraform-aws-ec2-instance](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance) module.  Although largely reduced in features and complexity for the Maksys usecase.  There are examples for use in that repo, along with further details should they be required.

## Contributing

See [DevOps_Handbook](https://github.com/maksystem-platform/DevOps_Handbook)

## PreRequisites

Blah blah testing

None

## Usage

This module is called from accounts to create EC2 instances in that account

```
module "maksys-ec2" {

  count = var.create_ec2 ? 1 : 0

  source = "git@github.com:maksystem-platform/terraform-aws-ec2.git"

  name = local.name

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "c5.xlarge" # used to set core count below
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  placement_group             = aws_placement_group.web.id
  associate_public_ip_address = true
  disable_api_stop            = false

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 8
    instance_metadata_tags      = "enabled"
  }

  network_interface = [
    {
      device_index          = 0
      network_interface_id  = aws_network_interface.this.id
      delete_on_termination = false
    }
  ]

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      tags = {
        Name = "my-root-block"
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 5
      throughput  = 200
      encrypted   = true
      kms_key_id  = aws_kms_key.this.arn
    }
  ]

  enable_volume_tags = false
  tags = local.tags

  instance_default_state     = "OFF"
  enable_resource_scheduling = true
  resource_schedule = {
    start = "00"
    stop  = "01"
    days = [
      "MON",
      "TUE",
      "WED",
      "THU",
      "FRI"
    ]
  }
}
```

NOTE: For multi instance example (e.g. multiple subnets in region) see [HERE](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/examples/complete/main.tf#L157)

## Generating SSH Keys for instances

You have the option to pass in the public part of your own SSH key, or the creation process to generate a key pair for you.  If you use generate key pair option then you will need to obtain the private key part from state using `terraform state show` or some other mechanism

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_aws.ct-management"></a> [aws.ct-management](#provider\_aws.ct-management) | >= 4.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_maksys-security-group"></a> [maksys-security-group](#module\_maksys-security-group) | git@github.com:maksystem-platform/terraform-aws-security-group.git | v1.0.0 |
| <a name="module_random_ip"></a> [random\_ip](#module\_random\_ip) | ./localmodules/random_ip | n/a |
| <a name="module_schedule"></a> [schedule](#module\_schedule) | git@github.com:maksystem-platform/terraform-aws-resource-scheduler.git//eventbridge-schedule | v2.2.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.maksys_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.maksys_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.maksys_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.maksys_ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.maksys_ec2_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_network_interface.maksys_eni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_route53_record.maksys_cnamd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [null_resource.maksys_get_account_hz](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.maksys_tls_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.maksys_ami_lookup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.maksys-ct-cmk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.maksys_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [local_file.maksys_account_hz](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_sg"></a> [additional\_sg](#input\_additional\_sg) | List of additional SG to attach to EC2/Network Interface | `list(any)` | `[]` | no |
| <a name="input_all_tags"></a> [all\_tags](#input\_all\_tags) | Map of all default tags | `map(any)` | n/a | yes |
| <a name="input_ami_architecture"></a> [ami\_architecture](#input\_ami\_architecture) | Architecture type for AMI (i386 or x86\_64 (default)) | `string` | `"x86_64"` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID if specific AMI ID is to be used | `string` | `""` | no |
| <a name="input_ami_latest"></a> [ami\_latest](#input\_ami\_latest) | Boolean for whether to take latest version of AMI - Useful when many versions of AMI matching criteria exist | `bool` | `true` | no |
| <a name="input_ami_name_pattern"></a> [ami\_name\_pattern](#input\_ami\_name\_pattern) | List of pattern(s) for AMI name to regex against AMI name | `list(any)` | <pre>[<br/>  "*al2*"<br/>]</pre> | no |
| <a name="input_ami_owners"></a> [ami\_owners](#input\_ami\_owners) | List of owners of AMI images to use - Can be account IDs or alias (e.g. amazon) | `list(any)` | <pre>[<br/>  "amazon"<br/>]</pre> | no |
| <a name="input_ami_root_device"></a> [ami\_root\_device](#input\_ami\_root\_device) | Root Block Device Type of AMI to use | `string` | `"ebs"` | no |
| <a name="input_ami_virt_type"></a> [ami\_virt\_type](#input\_ami\_virt\_type) | Virtualization type for AMI | `string` | `"hvm"` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability Zone the instance should be launched in. If not set, will be launched in the first AZ of the account private subnets AZs | `string` | `""` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability Zones that account private subnets exist in | `list(any)` | `[]` | no |
| <a name="input_create_iam_instance_profile"></a> [create\_iam\_instance\_profile](#input\_create\_iam\_instance\_profile) | Determines whether an IAM instance profile is created or to use an existing IAM instance profile | `bool` | `false` | no |
| <a name="input_create_r53_record"></a> [create\_r53\_record](#input\_create\_r53\_record) | Boolean to enable creating an R53 record for the instance | `bool` | `false` | no |
| <a name="input_create_sg"></a> [create\_sg](#input\_create\_sg) | Boolean for creating SG | `bool` | `true` | no |
| <a name="input_customer_hz"></a> [customer\_hz](#input\_customer\_hz) | The Route53 Hosted Zone in the customers account - In which an R53 record will be created | `string` | `""` | no |
| <a name="input_customer_nwhub_vpc_cidr"></a> [customer\_nwhub\_vpc\_cidr](#input\_customer\_nwhub\_vpc\_cidr) | VPC CIDE of customer network hub account - Used for default SG rules inbound access | `list(any)` | `[]` | no |
| <a name="input_ebs_block_device"></a> [ebs\_block\_device](#input\_ebs\_block\_device) | Additional EBS block devices to attach to the instance | `list(map(string))` | `[]` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `null` | no |
| <a name="input_ec2_key_pair"></a> [ec2\_key\_pair](#input\_ec2\_key\_pair) | Boolean flag to add key pair to EC2 instance on creation | `bool` | `false` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | List of egress rules to create by name. Eg. dns-tcp,http-80-tcp | `list(string)` | `[]` | no |
| <a name="input_enable_resource_scheduling"></a> [enable\_resource\_scheduling](#input\_enable\_resource\_scheduling) | Boolean flag for enabling and disabling resource scheduling. If `true`, must also pass `resource_schedule` | `bool` | `false` | no |
| <a name="input_enable_volume_tags"></a> [enable\_volume\_tags](#input\_enable\_volume\_tags) | Whether to enable volume tags (if enabled it conflicts with root\_block\_device tags) | `bool` | `true` | no |
| <a name="input_eni_host"></a> [eni\_host](#input\_eni\_host) | Private IP address Host Part (last  octet) to use for the ENI | `string` | `""` | no |
| <a name="input_eni_ip"></a> [eni\_ip](#input\_eni\_ip) | Private IP address to use for the ENI | `string` | `""` | no |
| <a name="input_ephemeral_block_device"></a> [ephemeral\_block\_device](#input\_ephemeral\_block\_device) | Customize Ephemeral (also known as Instance Store) volumes on the instance | `list(map(string))` | `[]` | no |
| <a name="input_generate_key_pair"></a> [generate\_key\_pair](#input\_generate\_key\_pair) | Boolean flag to generate an EC2 key pair | `bool` | `false` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies) | Policies attached to the IAM role | `map(string)` | <pre>{<br/>  "IAMReadOnlyAccess": "arn:aws:iam::aws:policy/IAMReadOnlyAccess"<br/>}</pre> | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role/profile created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name` or `name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rules to create by name. Eg. dns-tcp,http-80-tcp | `list(string)` | `[]` | no |
| <a name="input_instance_default_state"></a> [instance\_default\_state](#input\_instance\_default\_state) | Overrides resource scheduling and ensure instance is turned off at 00:00 UTC. Accepted values are ['ON', 'OFF'] | `string` | `"ON"` | no |
| <a name="input_instance_monitoring"></a> [instance\_monitoring](#input\_instance\_monitoring) | Flag to enable detailed monitoring on EC2 instance | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key Name to give to EC2 keys generated - Either key\_name or key\_prefix only to be provided | `string` | `null` | no |
| <a name="input_key_name_prefix"></a> [key\_name\_prefix](#input\_key\_name\_prefix) | Prefix to give to EC2 keys generated | `string` | `null` | no |
| <a name="input_launch_template"></a> [launch\_template](#input\_launch\_template) | Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template | `map(string)` | `null` | no |
| <a name="input_maintenance_options"></a> [maintenance\_options](#input\_maintenance\_options) | The maintenance options for the instance | `any` | `{}` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Customize the metadata options of the instance | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on EC2 instance created blah blah | `string` | `"maksys-instance"` | no |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Customize network interfaces to be attached at instance boot time | `list(map(string))` | `[]` | no |
| <a name="input_output_private_key"></a> [output\_private\_key](#input\_output\_private\_key) | Boolean flag for enabling or disabling output contents of generated private SSH key. | `bool` | `false` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address to associate with the instance in a VPC | `string` | `""` | no |
| <a name="input_private_key_algorithm"></a> [private\_key\_algorithm](#input\_private\_key\_algorithm) | Name of the algorithm to use when generating the private key. Currently-supported values are `RSA` and `ED25519` | `string` | `"RSA"` | no |
| <a name="input_private_key_rsa_bits"></a> [private\_key\_rsa\_bits](#input\_private\_key\_rsa\_bits) | When algorithm is `RSA`, the size of the generated RSA key, in bits (default: `4096`) | `number` | `4096` | no |
| <a name="input_product"></a> [product](#input\_product) | Name of product calling EC2 instance create - Will be used in R53 record along with PHZ/Domain | `string` | `"ec2"` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Public key value for an existing private key | `string` | `""` | no |
| <a name="input_resource_schedule"></a> [resource\_schedule](#input\_resource\_schedule) | Define start/stop schedule of the resource | <pre>object({<br/>    start = optional(string)<br/>    stop  = optional(string)<br/>    days  = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Customize details about the root block device of the instance. See Block Devices below for details | `list(any)` | `[]` | no |
| <a name="input_start_instance"></a> [start\_instance](#input\_start\_instance) | Boolean for whether to startup EC2 instance | `bool` | `true` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | Subnet CIDR the instance should be launched in. If not set, will be launched in the first of the account private subnets | `string` | `""` | no |
| <a name="input_subnet_cidrs"></a> [subnet\_cidrs](#input\_subnet\_cidrs) | Subnet CIDRs of account private subnets | `list(any)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID the instance should be launched in. If not set, will be launched in the first of the account private subnets | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs of account private subnets | `list(any)` | `[]` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user\_data\_base64 instead. | `string` | `null` | no |
| <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change) | When used in combination with user\_data or user\_data\_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set. | `bool` | `false` | no |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | Git Repo Version deployed - Only applied to primary resource for collection, i.e. VPC | `string` | n/a | yes |
| <a name="input_volume_tags"></a> [volume\_tags](#input\_volume\_tags) | A mapping of tags to assign to the devices created by the instance at launch time | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for current account | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_security_group"></a> [ec2\_security\_group](#output\_ec2\_security\_group) | n/a |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | n/a |
| <a name="output_ssh_key_pair"></a> [ssh\_key\_pair](#output\_ssh\_key\_pair) | Name of the SSH key pair provisioned on the instance |
| <a name="output_ssh_private_key"></a> [ssh\_private\_key](#output\_ssh\_private\_key) | Private key content of the generated key-pair |
<!-- END_TF_DOCS -->
# terraform-temp
