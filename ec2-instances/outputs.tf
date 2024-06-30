
output "instance_ids" {
  description = "IDs of created EC2 instances"
  value       = aws_instance.ec2_instance[*].id
}

output "private_ips" {
  description = "Private IPs of created EC2 instances"
  value       = aws_instance.ec2_instance[*].private_ip
}

output "public_ips" {
  description = "Public IPs of created EC2 instances"
  value       = aws_instance.ec2_instance[*].public_ip
}