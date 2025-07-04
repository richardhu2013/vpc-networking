output "app1_vpc_id" {
  description = "ID of the App1 VPC"
  value       = module.app1_vpc.vpc_id
}

output "app1_vpc_cidr" {
  description = "CIDR block of the App1 VPC"
  value       = module.app1_vpc.vpc_cidr_block
}

output "app1_app_subnet_ids" {
  description = "IDs of App1 application subnets"
  value       = module.app1_app_subnets.subnet_ids
}

output "app1_data_subnet_ids" {
  description = "IDs of App1 data subnets"
  value       = module.app1_data_subnets.subnet_ids
}

output "app1_app_sg_id" {
  description = "ID of App1 application tier security group"
  value       = module.app1_security_groups.app_tier_sg_id
}

output "app1_data_sg_id" {
  description = "ID of App1 data tier security group"
  value       = module.app1_security_groups.data_tier_sg_id
}

# output "app2_vpc_id" {
#   description = "ID of the App2 VPC"
#   value       = module.app2_vpc.vpc_id
# }

# output "app2_vpc_cidr" {
#   description = "CIDR block of the App2 VPC"
#   value       = module.app2_vpc.vpc_cidr_block
# }

# output "app2_app_subnet_ids" {
#   description = "IDs of App2 application subnets"
#   value       = module.app2_vpc.app_subnet_ids
# }

# output "app2_data_subnet_ids" {
#   description = "IDs of App2 data subnets"
#   value       = module.app2_vpc.data_subnet_ids
# }

# output "app2_app_sg_id" {
#   description = "ID of App2 application tier security group"
#   value       = module.app2_security_groups.app_tier_sg_id
# }

# output "app2_data_sg_id" {
#   description = "ID of App2 data tier security group"
#   value       = module.app2_security_groups.data_tier_sg_id
# }