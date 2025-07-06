/**
 * # Melbourne Region Cisco VPCs
 * This workspace creates Cisco Guest and Non-Guest VPCs for the Department of Education Victoria's
 * Melbourne region deployment using a modular approach.
 */

# Create IAM Role for Flow Logs
resource "aws_iam_role" "flow_log_role" {
  name = "cisco-vpc-flow-logs-role"
  
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
  name = "cisco-vpc-flow-logs-policy"
  role = aws_iam_role.flow_log_role.id
  
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
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Create CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "flow_log_group" {
  name              = "/aws/vpc/cisco-flowlogs"
  retention_in_days = 30
  
  tags = var.tags
}

# Get data about existing Transit Gateway
data "aws_ec2_transit_gateway" "this" {
  provider = aws.transit_account
  id = var.transit_gateway_id
}

# Get route tables from Transit Gateway
data "aws_ec2_transit_gateway_route_table" "cisco_guest" {
  provider = aws.transit_account
  
  filter {
    name   = "transit-gateway-id"
    values = [var.transit_gateway_id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["cisco-guest-vpc-tgw-att-RT"]
  }
}

data "aws_ec2_transit_gateway_route_table" "cisco_non_guest" {
  provider = aws.transit_account
  
  filter {
    name   = "transit-gateway-id"
    values = [var.transit_gateway_id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["cisco-non-guest-vpc-tgw-att-RT"]
  }
}

data "aws_ec2_transit_gateway_route_table" "security_vpc" {
  provider = aws.transit_account
  
  filter {
    name   = "transit-gateway-id"
    values = [var.transit_gateway_id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["sec-vpc-tgw-att-RT"]
  }
}

# Get data from IPAM pools if enabled
data "aws_vpc_ipam_pool" "cisco" {
  count = var.use_ipam ? 1 : 0
  provider = aws.transit_account
  
  # Look up the cisco IPAM pool by its ID or tags
  id = var.ipam_cisco_pool_id != "" ? var.ipam_cisco_pool_id : null
  
  dynamic "filter" {
    for_each = var.ipam_cisco_pool_id == "" ? [1] : []
    content {
      name   = "tag:Name"
      values = ["${var.ipam_name}-cisco-pool"]
    }
  }
}

# Create IPAM allocations for Cisco VPCs if IPAM is enabled
resource "aws_vpc_ipam_pool_cidr_allocation" "cisco_vpcs" {
  for_each = var.use_ipam ? var.cisco_vpcs : {}
  provider = aws.transit_account
  
  ipam_pool_id   = data.aws_vpc_ipam_pool.cisco[0].id
  netmask_length = var.cisco_vpc_netmask_length
  description    = "CIDR allocation for ${each.key} VPC"

}

# Create Cisco VPCs using the module
module "cisco_vpcs" {
  source = "./modules/cisco-vpc"
  providers = {
    aws.transit_account = aws.transit_account
  }
  
  for_each = var.cisco_vpcs
  
  # Basic VPC configuration
  name = lookup(each.value, "name", each.key)
  # Use IPAM-allocated CIDR if IPAM is enabled, otherwise use static CIDR
  vpc_cidr = var.use_ipam ? aws_vpc_ipam_pool_cidr_allocation.cisco_vpcs[each.key].cidr : each.value.cidr
  
  # Common configuration with ability to override
  availability_zones = lookup(each.value, "availability_zones", var.availability_zones)
  
  # Transit Gateway configuration
  transit_gateway_id = var.transit_gateway_id
  # Use appropriate route table based on VPC type
  transit_gateway_route_table_id = each.key == "guest" ? data.aws_ec2_transit_gateway_route_table.cisco_guest.id : data.aws_ec2_transit_gateway_route_table.cisco_non_guest.id
  
  # Cisco VPC specific configurations
  vpc_type = each.key  # "guest" or "non-guest"
  public_subnets_enabled = each.key == "guest" ? true : false
  create_internet_gateway = each.key == "guest" ? true : false
  create_nat_gateways = lookup(each.value, "create_nat_gateways", each.key == "guest" ? true : false)
  create_network_load_balancer = lookup(each.value, "create_network_load_balancer", true)
  nlb_internal = each.key == "guest" ? false : true
  lambda_enabled = lookup(each.value, "lambda_enabled", true)
  
  # Optional features with ability to override per VPC
  enable_vpc_flow_logs = lookup(each.value, "enable_vpc_flow_logs", var.enable_vpc_flow_logs)
  flow_log_role_arn = aws_iam_role.flow_log_role.arn
  flow_log_destination_arn = aws_cloudwatch_log_group.flow_log_group.arn
  aws_region = var.aws_region
  
  # Security configuration
  management_cidrs = lookup(each.value, "management_cidrs", var.management_cidrs)
  
  # Merge global tags with VPC-specific tags
  tags = merge(
    var.tags,
    {
      VpcType = each.key
      Description = each.key == "guest" ? "Cisco ISE Guest VPC with public-facing PSN components" : "Cisco ISE Non-Guest VPC with internal PSN components"
    },
    lookup(each.value, "tags", {})
  )
}