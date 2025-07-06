# main.tf
locals {
  ipam_pools = { for k, v in var.vpc_configs :
    k => v.use_ipam ? aws_vpc_ipam_pool_cidr_allocation[k][0].cidr : v.cidr
  }

  tgw_subnet_cidrs = { for k, cidr in local.ipam_pools :
    k => [
      cidrsubnet(cidr, 4, 0),
      cidrsubnet(cidr, 4, 1)
    ]
  }

  app_subnet_cidrs = { for k, cidr in local.ipam_pools :
    k => [
      cidrsubnet(cidr, 2, 1),
      cidrsubnet(cidr, 2, 2)
    ]
  }

  data_subnet_cidrs = { for k, cidr in local.ipam_pools :
    k => [
      cidrsubnet(cidr, 3, 6),
      cidrsubnet(cidr, 3, 7)
    ]
  }
}

resource "aws_iam_role" "flow_log_role" {
  for_each = var.vpc_configs

  name = "vpc-flow-logs-role-${each.key}"

  provider = aws[each.value.provider_alias]

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
  for_each = var.vpc_configs

  name = "vpc-flow-logs-policy-${each.key}"
  role = aws_iam_role.flow_log_role[each.key].id

  provider = aws[each.value.provider_alias]

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

resource "aws_cloudwatch_log_group" "flow_log_group" {
  for_each = var.vpc_configs

  name              = "/aws/vpc/flowlogs-${each.key}"
  retention_in_days = 30

  provider = aws[each.value.provider_alias]
  tags     = var.tags
}

resource "aws_vpc_ipam_pool_cidr_allocation" "this" {
  for_each = { for k, v in var.vpc_configs : k => v if v.use_ipam }

  provider       = aws.transit_account
  ipam_pool_id   = data.aws_vpc_ipam_pool.workload[0].id
  netmask_length = 24
  description    = "CIDR allocation for ${each.value.name}"
}

module "vpcs" {
  for_each = var.vpc_configs

  source = "./modules/vpc"

  vpc_name = each.value.name
  vpc_cidr = local.ipam_pools[each.key]

  providers = {
    aws                 = aws[each.value.provider_alias]
    aws.transit_account = aws.transit_account
  }

  tgw_attachment_subnet_ids = module.tgw_attachment_subnets[each.key].subnet_ids
  app_subnet_ids            = module.app_subnets[each.key].subnet_ids

  transit_gateway_id                         = var.transit_gateway_id
  transit_gateway_spoke_route_table_id       = data.aws_ec2_transit_gateway_route_table.spoke_vpc.id
  transit_gateway_security_route_table_id    = data.aws_ec2_transit_gateway_route_table.security_vpc.id
  transit_gateway_external_lb_route_table_id = data.aws_ec2_transit_gateway_route_table.external_lb_vpc.id
  transit_gateway_internal_lb_route_table_id = data.aws_ec2_transit_gateway_route_table.internal_lb_vpc.id

  create_ssm_endpoints     = var.enable_ssm_endpoints
  enable_vpc_flow_logs     = var.enable_vpc_flow_logs
  flow_log_role_arn        = aws_iam_role.flow_log_role[each.key].arn
  flow_log_destination_arn = aws_cloudwatch_log_group.flow_log_group[each.key].arn
  aws_region               = var.aws_region

  tags = merge(var.tags, { Application = each.value.name })
}

module "tgw_attachment_subnets" {
  for_each = var.vpc_configs

  source = "./modules/subnet"

  providers = {
    aws = aws[each.value.provider_alias]
  }

  vpc_id             = module.vpcs[each.key].vpc_id
  vpc_name           = each.value.name
  subnet_type        = "tgw-attachment"
  availability_zones = var.availability_zones
  subnet_cidrs       = local.tgw_subnet_cidrs[each.key]

  route_table_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.transit_gateway_id
    }
  ]

  tags = merge(var.tags, { Application = each.value.name })
}

module "app_subnets" {
  for_each = var.vpc_configs

  source = "./modules/subnet"

  providers = {
    aws = aws[each.value.provider_alias]
  }

  vpc_id             = module.vpcs[each.key].vpc_id
  vpc_name           = each.value.name
  subnet_type        = "application"
  availability_zones = var.availability_zones
  subnet_cidrs       = local.app_subnet_cidrs[each.key]

  route_table_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.transit_gateway_id
    }
  ]

  tags = merge(var.tags, { Application = each.value.name })
}

module "data_subnets" {
  for_each = var.vpc_configs

  source = "./modules/subnet"

  providers = {
    aws = aws[each.value.provider_alias]
  }

  vpc_id             = module.vpcs[each.key].vpc_id
  vpc_name           = each.value.name
  subnet_type        = "data"
  availability_zones = var.availability_zones
  subnet_cidrs       = local.data_subnet_cidrs[each.key]

  route_table_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.transit_gateway_id
    }
  ]

  tags = merge(var.tags, { Application = each.value.name })
}

module "security_groups" {
  for_each = var.vpc_configs

  source = "./modules/security-groups"

  providers = {
    aws = aws[each.value.provider_alias]
  }

  vpc_id           = module.vpcs[each.key].vpc_id
  vpc_name         = each.value.name
  f5_lb_cidrs      = var.f5_lb_cidrs
  management_cidrs = var.management_cidrs

  tags = merge(var.tags, { Application = each.value.name })
}
