variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = "maksys-instance"
}

variable "vpc_id" {
  description = "VPC ID for current account"
  type        = string
}

variable "customer_nwhub_vpc_cidr" {
  description = "VPC CIDE of customer network hub account - Used for default SG rules inbound access"
  type        = list(any)
  default     = []
}

variable "all_tags" {
  description = "Map of all default tags"
  type        = map(any)
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone the instance should be launched in. If not set, will be launched in the first AZ of the account private subnets AZs"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID the instance should be launched in. If not set, will be launched in the first of the account private subnets"
  default     = ""
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR the instance should be launched in. If not set, will be launched in the first of the account private subnets"
  default     = ""
}

variable "availability_zones" {
  type        = list(any)
  description = "Availability Zones that account private subnets exist in"
  default     = []
}

variable "subnet_ids" {
  type        = list(any)
  description = "Subnet IDs of account private subnets"
  default     = []
}

variable "subnet_cidrs" {
  type        = list(any)
  description = "Subnet CIDRs of account private subnets"
  default     = []
}

variable "start_instance" {
  description = "Boolean for whether to startup EC2 instance"
  type        = bool
  default     = true
}

variable "ami_id" {
  description = "AMI ID if specific AMI ID is to be used"
  type        = string
  default     = ""
}

variable "ami_name_pattern" {
  description = "List of pattern(s) for AMI name to regex against AMI name"
  type        = list(any)
  default     = ["*al2*"]
}

variable "ami_owners" {
  description = "List of owners of AMI images to use - Can be account IDs or alias (e.g. amazon)"
  type        = list(any)
  default     = ["amazon"]
}

variable "ami_latest" {
  description = "Boolean for whether to take latest version of AMI - Useful when many versions of AMI matching criteria exist"
  type        = bool
  default     = true
}

variable "ami_architecture" {
  description = "Architecture type for AMI (i386 or x86_64 (default))"
  type        = string
  default     = "x86_64"
}

variable "ami_virt_type" {
  description = "Virtualization type for AMI"
  type        = string
  default     = "hvm"
}

variable "ami_root_device" {
  description = "Root Block Device Type of AMI to use"
  type        = string
  default     = "ebs"
}

variable "maintenance_options" {
  description = "The maintenance options for the instance"
  type        = any
  default     = {}
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = null
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  type        = list(map(string))
  default     = []
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}

variable "launch_template" {
  description = "Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template"
  type        = map(string)
  default     = null
}

variable "metadata_options" {
  description = "Customize the metadata options of the instance"
  type        = map(string)
  default     = {}
}

variable "network_interface" {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = list(map(string))
  default     = []
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = ""
}

variable "eni_ip" {
  description = "Private IP address to use for the ENI"
  type        = string
  default     = ""
}

variable "eni_host" {
  description = "Private IP address Host Part (last  octet) to use for the ENI"
  type        = string
  default     = ""
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = list(any)
  default     = []
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set."
  type        = bool
  default     = false
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = map(string)
  default     = {}
}

variable "enable_volume_tags" {
  description = "Whether to enable volume tags (if enabled it conflicts with root_block_device tags)"
  type        = bool
  default     = true
}

variable "create_sg" {
  description = "Boolean for creating SG"
  type        = bool
  default     = true
}

variable "create_iam_instance_profile" {
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile"
  type        = bool
  default     = false
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name` or `name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Policies attached to the IAM role"
  type        = map(string)
  default = {
    IAMReadOnlyAccess = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  }
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}

variable "create_r53_record" {
  description = "Boolean to enable creating an R53 record for the instance"
  type        = bool
  default     = false
}

variable "customer_hz" {
  description = "The Route53 Hosted Zone in the customers account - In which an R53 record will be created"
  type        = string
  default     = ""
}

variable "product" {
  description = "Name of product calling EC2 instance create - Will be used in R53 record along with PHZ/Domain"
  type        = string
  default     = "ec2"
}

variable "instance_monitoring" {
  description = "Flag to enable detailed monitoring on EC2 instance"
  type        = bool
  default     = true
}

variable "additional_sg" {
  description = "List of additional SG to attach to EC2/Network Interface"
  type        = list(any)
  default     = []
}

variable "ec2_key_pair" {
  description = "Boolean flag to add key pair to EC2 instance on creation"
  type        = bool
  default     = false
}

variable "generate_key_pair" {
  description = "Boolean flag to generate an EC2 key pair"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Key Name to give to EC2 keys generated - Either key_name or key_prefix only to be provided"
  type        = string
  default     = null
}

variable "key_name_prefix" {
  description = "Prefix to give to EC2 keys generated"
  type        = string
  default     = null
}

variable "public_key" {
  description = "Public key value for an existing private key"
  type        = string
  default     = ""
}

variable "private_key_algorithm" {
  description = "Name of the algorithm to use when generating the private key. Currently-supported values are `RSA` and `ED25519`"
  type        = string
  default     = "RSA"
}

variable "private_key_rsa_bits" {
  description = "When algorithm is `RSA`, the size of the generated RSA key, in bits (default: `4096`)"
  type        = number
  default     = 4096
}

variable "enable_resource_scheduling" {
  description = "Boolean flag for enabling and disabling resource scheduling. If `true`, must also pass `resource_schedule`"
  type        = bool
  default     = false
}

variable "resource_schedule" {
  description = "Define start/stop schedule of the resource"
  type = object({
    start = optional(string)
    stop  = optional(string)
    days  = optional(list(string))
  })
  default = null
}

variable "instance_default_state" {
  description = "Overrides resource scheduling and ensure instance is turned off at 00:00 UTC. Accepted values are ['ON', 'OFF']"
  type        = string
  default     = "ON"
  validation {
    condition     = contains(["ON", "OFF"], var.instance_default_state)
    error_message = "Valid values for instance_default_state are (ON, OFF)."
  }
}

variable "output_private_key" {
  description = "Boolean flag for enabling or disabling output contents of generated private SSH key."
  type        = bool
  default     = false
}

variable "version_tag" {
  description = "Git Repo Version deployed - Only applied to primary resource for collection, i.e. VPC"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules to create by name. Eg. dns-tcp,http-80-tcp"
  type        = list(string)
  default     = []
}

variable "egress_rules" {
  description = "List of egress rules to create by name. Eg. dns-tcp,http-80-tcp"
  type        = list(string)
  default     = []
}
