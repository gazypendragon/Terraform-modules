#export the IDs of created EC2 instances
output "instance_ids" {
  value = aws_instance.ec2_instance[*].id
}

#export Private IPs of created EC2 instances
output "private_ips" {
  value = aws_instance.ec2_instance[*].private_ip
}

#export Public IPs of created EC2 instances
output "public_ips" {
  value = aws_instance.ec2_instance[*].public_ip
}