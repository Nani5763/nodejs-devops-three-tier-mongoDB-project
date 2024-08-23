output "aws_region" {
    description = "Jumphost Server region"
    value = "us-east-1"
}
output "jumphost_public_ip" {
  description = "Public IP address of the EC2 jumphost"
  value       = aws_instance.pavan.id
}