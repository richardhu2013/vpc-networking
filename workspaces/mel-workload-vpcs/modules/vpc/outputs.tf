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
# output "tgw_attachment_subnet_ids" {
#   description = "List of IDs of TGW attachment subnets"
#   value       = module.tgw_attachment_subnets.subnet_ids
# }

# output "tgw_attachment_subnet_cidrs" {
#   description = "List of CIDR blocks of TGW attachment subnets"
#   value       = module.tgw_attachment_subnets.subnet_cidrs
# }

# output "app_subnet_ids" {
#   description = "List of IDs of application subnets"
#   value       = module.app_subnets.subnet_ids
# }

# output "app_subnet_cidrs" {
#   description = "List of CIDR blocks of application subnets"
#   value       = module.app_subnets.subnet_cidrs
# }

# output "data_subnet_ids" {
#   description = "List of IDs of data subnets"
#   value       = module.data_subnets.subnet_ids
# }

# output "data_subnet_cidrs" {
#   description = "List of CIDR blocks of data subnets"
#   value       = module.data_subnets.subnet_cidrs
# }

# output "tgw_attachment_id" {
#   description = "ID of the Transit Gateway attachment"
#   value       = aws_ec2_transit_gateway_vpc_attachment.this.id
# }