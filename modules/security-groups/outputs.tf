output "app_tier_sg_id" {
  description = "ID of the application tier security group"
  value       = aws_security_group.app_tier.id
}

output "data_tier_sg_id" {
  description = "ID of the data tier security group"
  value       = aws_security_group.data_tier.id
}

output "management_sg_id" {
  description = "ID of the management security group"
  value       = aws_security_group.management.id
}