output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "tgw_attachment_subnet_ids" {
  description = "List of IDs of TGW attachment subnets"
  value       = aws_subnet.tgw_attachment[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = var.create_internet_gateway ? aws_internet_gateway.this[0].id : null
}

output "nat_gateway_ids" {
  description = "List of IDs of NAT Gateways"
  value       = var.create_nat_gateways ? aws_nat_gateway.this[*].id : []
}

output "tgw_attachment_id" {
  description = "ID of the Transit Gateway attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "psn_security_group_id" {
  description = "ID of the PSN security group"
  value       = aws_security_group.psn.id
}

output "pan_security_group_id" {
  description = "ID of the PAN security group"
  value       = aws_security_group.pan.id
}

output "mnt_security_group_id" {
  description = "ID of the MnT security group"
  value       = aws_security_group.mnt.id
}

output "nlb_id" {
  description = "ID of the Network Load Balancer"
  value       = var.create_network_load_balancer ? aws_lb.radius[0].id : null
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = var.create_network_load_balancer ? aws_lb.radius[0].dns_name : null
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = var.lambda_enabled ? aws_lambda_function.cisco_handler[0].arn : null
}