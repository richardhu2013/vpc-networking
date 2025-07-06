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

output "app1_tgw_attachment_subnet_ids" {
  description = "List of IDs of TGW attachment subnets"
  value       = module.app1_tgw_attachment_subnets.subnet_ids
}

output "app1_tgw_attachment_subnet_cidrs" {
  description = "List of CIDR blocks of TGW attachment subnets"
  value       = module.app1_tgw_attachment_subnets.subnet_cidrs
}

output "app1_app_subnet_ids" {
  description = "List of IDs of application subnets"
  value       = module.app1_app_subnets.subnet_ids
}

output "app1_app_subnet_cidrs" {
  description = "List of CIDR blocks of application subnets"
  value       = module.app1_app_subnets.subnet_cidrs
}

output "app1_data_subnet_ids" {
  description = "List of IDs of data subnets"
  value       = module.app1_data_subnets.subnet_ids
}

output "app1_data_subnet_cidrs" {
  description = "List of CIDR blocks of data subnets"
  value       = module.app1_data_subnets.subnet_cidrs
}

output "app1_tgw_attachment_id" {
  description = "ID of the Transit Gateway attachment"
  value       = module.app1_vpc.transit_gateway_attachment_id
}

# output "app2_vpc_id" {
#   description = "ID of the App1 VPC"
#   value       = module.app2_vpc.vpc_id
# }

# output "app2_vpc_cidr" {
#   description = "CIDR block of the App1 VPC"
#   value       = module.app2_vpc.vpc_cidr_block
# }

# output "app2_app_subnet_ids" {
#   description = "IDs of App1 application subnets"
#   value       = module.app2_app_subnets.subnet_ids
# }

# output "app2_data_subnet_ids" {
#   description = "IDs of App1 data subnets"
#   value       = module.app2_data_subnets.subnet_ids
# }

# output "app2_app_sg_id" {
#   description = "ID of App1 application tier security group"
#   value       = module.app2_security_groups.app_tier_sg_id
# }

# output "app2_data_sg_id" {
#   description = "ID of App1 data tier security group"
#   value       = module.app2_security_groups.data_tier_sg_id
# }

# output "app2_tgw_attachment_subnet_ids" {
#   description = "List of IDs of TGW attachment subnets"
#   value       = module.app2_tgw_attachment_subnets.subnet_ids
# }

# output "app2_tgw_attachment_subnet_cidrs" {
#   description = "List of CIDR blocks of TGW attachment subnets"
#   value       = module.app2_tgw_attachment_subnets.subnet_cidrs
# }

# output "app2_app_subnet_cidrs" {
#   description = "List of CIDR blocks of application subnets"
#   value       = module.app2_app_subnets.subnet_cidrs
# }

# output "app2_data_subnet_cidrs" {
#   description = "List of CIDR blocks of data subnets"
#   value       = module.app2_data_subnets.subnet_cidrs
# }

# output "app2_tgw_attachment_id" {
#   description = "ID of the Transit Gateway attachment"
#   value       = module.app2_vpc.transit_gateway_attachment_id
# }