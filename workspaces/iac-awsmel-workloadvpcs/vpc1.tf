# Define the App1 VPC CIDR block and subnet CIDRs
locals {
  app1_vpc_cidr = var.use_ipam ? aws_vpc_ipam_pool_cidr_allocation.app1[0].cidr : var.app1_vpc_cidr

  # Define subnet CIDR blocks
  app1_tgw_subnet_cidrs = [
    cidrsubnet(local.app1_vpc_cidr, 4, 0), //10.100.16.0/28
    cidrsubnet(local.app1_vpc_cidr, 4, 1)  //10.100.16.16/28
  ]
  app1_app_subnet_cidrs = [
    cidrsubnet(local.app1_vpc_cidr, 2, 1), //10.100.16.64/26
    cidrsubnet(local.app1_vpc_cidr, 2, 2)  //10.100.16.128/26
  ]
  app1_data_subnet_cidrs = [
    cidrsubnet(local.app1_vpc_cidr, 3, 6), // 10.100.16.192/27
    cidrsubnet(local.app1_vpc_cidr, 3, 7)  // 10.100.16.224/27
  ]
}

# Create IAM Role for Flow Logs
resource "aws_iam_role" "flow_log_role" {
  provider = aws.app1
  name     = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_log_policy" {
  provider = aws.app1
  name     = "vpc-flow-logs-policy"
  role     = aws_iam_role.flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Create CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "flow_log_group" {
  provider = aws.app1

  name              = "/aws/vpc/app1/flowlogs"
  retention_in_days = 30

  tags = var.tags
}

# Create IPAM allocations for App1 VPC
resource "aws_vpc_ipam_pool_cidr_allocation" "app1" {
  count    = var.use_ipam ? 1 : 0
  provider = aws.transit_account

  ipam_pool_id   = data.aws_vpc_ipam_pool.workload[0].id
  netmask_length = 24
  description    = "CIDR allocation for ${var.app1_name} VPC"
}

module "app1_tgw_attachment_subnets" {
  source = "./modules/subnet"

  providers = {
    aws = aws.app1
  }
  vpc_id             = module.app1_vpc.vpc_id
  vpc_name           = "app1"
  subnet_type        = "tgw-attachment"
  availability_zones = var.availability_zones
  subnet_cidrs       = local.app1_tgw_subnet_cidrs

  route_table_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.transit_gateway_id
    }
  ]

  tags = merge(
    var.tags,
    {
      Application = "App1"
    }
  )
}

module "app1_app_subnets" {
  source = "./modules/subnet"
  providers = {
    aws = aws.app1
  }

  vpc_id             = module.app1_vpc.vpc_id
  vpc_name           = "app1"
  subnet_type        = "application"
  availability_zones = var.availability_zones
  subnet_cidrs       = local.app1_app_subnet_cidrs

  route_table_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.transit_gateway_id
    }
  ]

  tags = merge(
    var.tags,
    {
      Application = "App1"
    }
  )
}

module "app1_data_subnets" {
  source = "./modules/subnet"
  providers = {
    aws = aws.app1
  }
  vpc_id             = module.app1_vpc.vpc_id
  vpc_name           = "app1"
  subnet_type        = "data"
  availability_zones = var.availability_zones
  subnet_cidrs       = local.app1_data_subnet_cidrs

  route_table_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.transit_gateway_id
    }
  ]

  tags = merge(
    var.tags,
    {
      Application = "App1"
    }
  )
}

module "app1_vpc" {
  source = "./modules/vpc"

  vpc_name = "app1-vpc"
  vpc_cidr = local.app1_vpc_cidr

  providers = {
    aws                 = aws.app1
    aws.transit_account = aws.transit_account
  }
  # azs      = var.availability_zones

  # Pass the subnet IDs created above
  tgw_attachment_subnet_ids = module.app1_tgw_attachment_subnets.subnet_ids
  app_subnet_ids            = module.app1_app_subnets.subnet_ids

  # Transit Gateway configuration
  transit_gateway_id                         = var.transit_gateway_id
  transit_gateway_spoke_route_table_id       = data.aws_ec2_transit_gateway_route_table.spoke_vpc.id
  transit_gateway_security_route_table_id    = data.aws_ec2_transit_gateway_route_table.security_vpc.id
  transit_gateway_external_lb_route_table_id = data.aws_ec2_transit_gateway_route_table.external_lb_vpc.id
  transit_gateway_internal_lb_route_table_id = data.aws_ec2_transit_gateway_route_table.internal_lb_vpc.id

  # Optional features
  create_ssm_endpoints = var.enable_ssm_endpoints
  enable_vpc_flow_logs = var.enable_vpc_flow_logs
  flow_log_role_arn        = aws_iam_role.flow_log_role.arn
  flow_log_destination_arn = aws_cloudwatch_log_group.flow_log_group.arn
  aws_region               = var.aws_region

  tags = merge(
    var.tags,
    {
      Application = "App1"
    }
  )
}

# 5. Create security groups
module "app1_security_groups" {
  source = "./modules/security-groups"
  providers = {
    aws = aws.app1
  }

  vpc_id           = module.app1_vpc.vpc_id
  vpc_name         = "app1"
  f5_lb_cidrs      = var.f5_lb_cidrs
  management_cidrs = var.management_cidrs

  tags = merge(
    var.tags,
    {
      Application = "App1"
    }
  )
}