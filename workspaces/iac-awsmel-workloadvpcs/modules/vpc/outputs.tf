output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "tgw_attachment_id" {
  description = "ID of the Transit Gateway attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway attachment (alias for tgw_attachment_id)"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}
