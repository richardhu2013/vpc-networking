output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_arn
}

output "route_table_ids" {
  description = "Map of route table names to IDs"
  value       = module.route_tables.route_table_ids
}

output "spoke_vpc_route_table_id" {
  description = "ID of the route table for spoke VPCs"
  value       = module.route_tables.route_table_ids["spoke_vpc_tgw_att_RT"]
}

# output "security_vpc_route_table_id" {
#   description = "ID of the route table for Security VPC"
#   value       = module.route_tables.route_table_ids["sec-vpc-tgw-att-RT"]
# }

output "external_lb_vpc_route_table_id" {
  description = "ID of the route table for External LB VPC"
  value       = module.route_tables.route_table_ids["ext-lb-vpc-tgw-att-rt"]
}

output "internal_lb_vpc_route_table_id" {
  description = "ID of the route table for Internal LB VPC"
  value       = module.route_tables.route_table_ids["int-lb-vpc-tgw-att-rt"]
}

output "cisco_guest_vpc_route_table_id" {
  description = "ID of the route table for Cisco Guest VPC"
  value       = module.route_tables.route_table_ids["cisco-guest-vpc-tgw-att-RT"]
}

output "cisco_non_guest_vpc_route_table_id" {
  description = "ID of the route table for Cisco Non-Guest VPC"
  value       = module.route_tables.route_table_ids["cisco-non-guest-vpc-tgw-att-RT"]
}

output "onprem_route_table_id" {
  description = "ID of the route table for On-Premises connections"
  value       = module.route_tables.route_table_ids["onprem-tgw-att-RT"]
}

output "direct_connect_gateway_id" {
  description = "ID of the Direct Connect Gateway (if created)"
  value       = var.enable_dx_gateway ? module.transit_gateway.dx_gateway_id : null
}

output "ram_resource_share_arn" {
  description = "ARN of the RAM resource share (if created)"
  value       = var.enable_ram_sharing ? aws_ram_resource_share.tgw_share[0].arn : null
}

# IPAM Outputs
output "ipam_id" {
  description = "ID of the created IPAM"
  value       = module.ipam.ipam_id
}

output "ipam_arn" {
  description = "ARN of the created IPAM"
  value       = module.ipam.ipam_arn
}

output "ipam_private_scope_id" {
  description = "ID of the private scope"
  value       = module.ipam.private_scope_id
}

output "ipam_top_level_pool_id" {
  description = "ID of the top-level IPAM pool"
  value       = module.ipam.top_level_pool_id
}

output "ipam_regional_pool_id" {
  description = "ID of the regional IPAM pool"
  value       = module.ipam.regional_pool_id
}

output "ipam_functional_pool_ids" {
  description = "Map of functional pool names to their IDs"
  value       = module.ipam.functional_pool_ids
}

output "ipam_ram_resource_share_arn" {
  description = "ARN of the RAM resource share for IPAM (if created)"
  value       = module.ipam.ram_resource_share_arn
}