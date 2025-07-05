# Generate outputs for all Cisco VPCs using for_each
output "vpc_ids" {
  description = "Map of VPC IDs by type"
  value = {
    for key, vpc in module.cisco_vpcs : key => vpc.vpc_id
  }
}

output "vpc_cidrs" {
  description = "Map of VPC CIDR blocks by type"
  value = {
    for key, vpc in module.cisco_vpcs : key => vpc.vpc_cidr_block
  }
}

# Guest VPC specific outputs
output "guest_vpc_id" {
  description = "ID of the Cisco Guest VPC"
  value       = module.cisco_vpcs["guest"].vpc_id
}

output "guest_vpc_cidr" {
  description = "CIDR block of the Cisco Guest VPC"
  value       = module.cisco_vpcs["guest"].vpc_cidr_block
}

output "guest_public_subnet_ids" {
  description = "IDs of Cisco Guest VPC public subnets"
  value       = module.cisco_vpcs["guest"].public_subnet_ids
}

output "guest_private_subnet_ids" {
  description = "IDs of Cisco Guest VPC private subnets"
  value       = module.cisco_vpcs["guest"].private_subnet_ids
}

output "guest_tgw_attachment_subnet_ids" {
  description = "IDs of Cisco Guest VPC TGW attachment subnets"
  value       = module.cisco_vpcs["guest"].tgw_attachment_subnet_ids
}

output "guest_nlb_dns_name" {
  description = "DNS name of the Cisco Guest VPC Network Load Balancer"
  value       = module.cisco_vpcs["guest"].nlb_dns_name
}

# Non-Guest VPC specific outputs
output "non_guest_vpc_id" {
  description = "ID of the Cisco Non-Guest VPC"
  value       = module.cisco_vpcs["non-guest"].vpc_id
}

output "non_guest_vpc_cidr" {
  description = "CIDR block of the Cisco Non-Guest VPC"
  value       = module.cisco_vpcs["non-guest"].vpc_cidr_block
}

output "non_guest_private_subnet_ids" {
  description = "IDs of Cisco Non-Guest VPC private subnets"
  value       = module.cisco_vpcs["non-guest"].private_subnet_ids
}

output "non_guest_tgw_attachment_subnet_ids" {
  description = "IDs of Cisco Non-Guest VPC TGW attachment subnets"
  value       = module.cisco_vpcs["non-guest"].tgw_attachment_subnet_ids
}

output "non_guest_nlb_dns_name" {
  description = "DNS name of the Cisco Non-Guest VPC Network Load Balancer"
  value       = module.cisco_vpcs["non-guest"].nlb_dns_name
}