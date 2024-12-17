variable "netname" {
  description = "Arbitrary value that, when changed, will trigger recreation of resource - Static in our case as do not want to re-trigger"
  default     = "default"
  type        = string
}

variable "subnet" {
  description = "Subnet CIDR used in output cidrhost calculation"
  type        = string
}
