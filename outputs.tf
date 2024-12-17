output "ec2_security_group" {
  value = try(module.maksys-security-group[0].security_group_id, "")
}

output "ssh_key_pair" {
  description = "Name of the SSH key pair provisioned on the instance"
  value       = try(aws_key_pair.maksys_ec2_key_pair[0].key_name, "")
}

output "instance_id" {
  value = try(aws_instance.maksys_ec2_instance[0].id, "")
}

output "ssh_private_key" {
  description = "Private key content of the generated key-pair"
  sensitive   = true
  value       = var.output_private_key && var.generate_key_pair ? tls_private_key.maksys_tls_key[0].private_key_openssh : ""
}
