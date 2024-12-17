
output "random_ip" {
  value = cidrhost(var.subnet, random_integer.octet.result)
}
