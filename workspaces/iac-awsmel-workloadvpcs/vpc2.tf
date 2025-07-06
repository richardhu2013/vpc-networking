# /**
#  * # Melbourne Region Workload VPC - App2
#  * This workspace creates a standard three-tier workload VPC (App2) for the Department of Education Victoria's
#  * Melbourne region deployment using the VPC module.
#  */

# # Define the App2 VPC CIDR block and subnet CIDRs
# locals {
#   app2_vpc_cidr = var.use_ipam ? aws_vpc_ipam_pool_cidr_allocation.app2[0].cidr : var.app2_vpc_cidr

#   # Define subnet CIDR blocks
#   app2_tgw_subnet_cidrs = [
#     cidrsubnet(local.app2_vpc_cidr, 4, 0), //10.100.16.0/28
#     cidrsubnet(local.app2_vpc_cidr, 4, 1)  //10.100.16.16/28
#   ]
#   app2_app_subnet_cidrs = [
#     cidrsubnet(local.app2_vpc_cidr, 2, 1), //10.100.16.64/26
#     cidrsubnet(local.app2_vpc_cidr, 2, 2)  //10.100.16.128/26
#   ]
#   app2_data_subnet_cidrs = [
#     cidrsubnet(local.app2_vpc_cidr, 3, 6), // 10.100.16.192/27
#     cidrsubnet(local.app2_vpc_cidr, 3, 7)  // 10.100.16.224/27
#   ]
# }

# # Create IAM Role for Flow Logs
# resource "aws_iam_role" "flow_log_role_app2" {
#   provider = aws.app2
#   name     = "vpc-flow-logs-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "vpc-flow-logs.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "flow_log_policy_app2" {
#   provider = aws.app2
#   name     = "vpc-flow-logs-policy"
#   role     = aws_iam_role.flow_log_role_app2.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:DescribeLogGroups",
#           "logs:DescribeLogStreams"
#         ],
#         Effect   = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Create CloudWatch Log Group for Flow Logs
# resource "aws_cloudwatch_log_group" "flow_log_group_app2" {
#   provider = aws.app2

#   name              = "/aws/vpc/flowlogs"
#   retention_in_days = 30

#   tags = var.tags
# }

# # Create IPAM allocations for App2 VPC
# resource "aws_vpc_ipam_pool_cidr_allocation" "app2" {
#   count    = var.use_ipam ? 1 : 0
#   provider = aws.transit_account

#   ipam_pool_id   = data.aws_vpc_ipam_pool.workload[0].id
#   netmask_length = 24
#   description    = "CIDR allocation for ${var.app2_name} VPC"
# }


# # 1. Create TGW attachment subnets first
# module "app2_tgw_attachment_subnets" {
#   source = "./modules/subnet"
#   providers = {
#     aws = aws.app2
#   }

#   vpc_id             = module.app2_vpc.vpc_id
#   vpc_name           = "app2"
#   subnet_type        = "tgw-attachment"
#   availability_zones = var.availability_zones
#   subnet_cidrs       = local.app2_tgw_subnet_cidrs

#   route_table_routes = [
#     {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = var.transit_gateway_id
#     }
#   ]

#   tags = merge(
#     var.tags,
#     {
#       Application = "App2"
#     }
#   )
# }

# # 2. Create App subnets
# module "app2_app_subnets" {
#   source = "./modules/subnet"
#   providers = {
#     aws = aws.app2
#   }

#   vpc_id             = module.app2_vpc.vpc_id
#   vpc_name           = "app2"
#   subnet_type        = "application"
#   availability_zones = var.availability_zones
#   subnet_cidrs       = local.app2_app_subnet_cidrs

#   route_table_routes = [
#     {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = var.transit_gateway_id
#     }
#   ]

#   tags = merge(
#     var.tags,
#     {
#       Application = "App2"
#     }
#   )
# }

# # 3. Create Data subnets
# module "app2_data_subnets" {
#   source = "./modules/subnet"
#   providers = {
#     aws = aws.app2
#   }

#   vpc_id             = module.app2_vpc.vpc_id
#   vpc_name           = "app2"
#   subnet_type        = "data"
#   availability_zones = var.availability_zones
#   subnet_cidrs       = local.app2_data_subnet_cidrs

#   route_table_routes = [
#     {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = var.transit_gateway_id
#     }
#   ]

#   tags = merge(
#     var.tags,
#     {
#       Application = "App2"
#     }
#   )
# }

# # 4. Create VPC using the VPC module
# module "app2_vpc" {
#   source = "./modules/vpc"

#   vpc_name = "app2-vpc"
#   vpc_cidr = local.app2_vpc_cidr

#   providers = {
#     aws                 = aws.app2
#     aws.transit_account = aws.transit_account
#   }
#   # azs      = var.availability_zones

#   tgw_attachment_subnet_ids = module.app2_tgw_attachment_subnets.subnet_ids
#   app_subnet_ids            = module.app2_app_subnets.subnet_ids

#   # Transit Gateway configuration
#   transit_gateway_id                         = var.transit_gateway_id
#   transit_gateway_spoke_route_table_id       = data.aws_ec2_transit_gateway_route_table.spoke_vpc.id
#   transit_gateway_security_route_table_id    = data.aws_ec2_transit_gateway_route_table.security_vpc.id
#   transit_gateway_external_lb_route_table_id = data.aws_ec2_transit_gateway_route_table.external_lb_vpc.id
#   transit_gateway_internal_lb_route_table_id = data.aws_ec2_transit_gateway_route_table.internal_lb_vpc.id

#   # Optional features
#   create_ssm_endpoints = var.enable_ssm_endpoints
#   enable_vpc_flow_logs = var.enable_vpc_flow_logs
#   # flow_log_role_arn = var.flow_log_role_arn
#   # flow_log_destination_arn = var.flow_log_destination_arn
#   flow_log_role_arn        = aws_iam_role.flow_log_role_app2.arn
#   flow_log_destination_arn = aws_cloudwatch_log_group.flow_log_group_app2.arn
#   aws_region               = var.aws_region

#   tags = merge(
#     var.tags,
#     {
#       Application = "App2"
#     }
#   )
# }

# # 5. Create security groups
# module "app2_security_groups" {
#   source = "./modules/security-groups"
#   providers = {
#     aws = aws.app2
#   }

#   vpc_id           = module.app2_vpc.vpc_id
#   vpc_name         = "app2"
#   f5_lb_cidrs      = var.f5_lb_cidrs
#   management_cidrs = var.management_cidrs

#   tags = merge(
#     var.tags,
#     {
#       Application = "App2"
#     }
#   )
# }