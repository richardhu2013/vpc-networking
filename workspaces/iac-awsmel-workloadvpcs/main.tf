/**
 * # Melbourne Region Workload VPC - App1
 * This workspace creates a standard three-tier workload VPC (App1) for the Department of Education Victoria's
 * Melbourne region deployment using the VPC module.
 */



# Get data about existing Transit Gateway
data "aws_ec2_transit_gateway" "this" {
  provider = aws.transit_account
  id       = var.transit_gateway_id
}

# Get route tables from Transit Gateway
data "aws_ec2_transit_gateway_route_table" "spoke_vpc" {
  provider = aws.transit_account

  filter {
    name   = "transit-gateway-id"
    values = [var.transit_gateway_id]
  }

  filter {
    name   = "tag:Name"
    values = ["spoke_vpc_tgw_att_RT"]
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

data "aws_ec2_transit_gateway_route_table" "external_lb_vpc" {
  provider = aws.transit_account

  filter {
    name   = "transit-gateway-id"
    values = [var.transit_gateway_id]
  }

  filter {
    name   = "tag:Name"
    values = ["ext-lb-vpc-tgw-att-rt"]
  }
}

data "aws_ec2_transit_gateway_route_table" "internal_lb_vpc" {
  provider = aws.transit_account

  filter {
    name   = "transit-gateway-id"
    values = [var.transit_gateway_id]
  }

  filter {
    name   = "tag:Name"
    values = ["int-lb-vpc-tgw-att-rt"]
  }
}

# Get data from IPAM pools if enabled
data "aws_vpc_ipam_pool" "workload" {
  count    = var.use_ipam ? 1 : 0
  provider = aws.transit_account

  # Look up the workload IPAM pool by its ID or tags
  # The ID is preferred when available via remote state or data source
  id = var.ipam_workload_pool_id != "" ? var.ipam_workload_pool_id : null

  dynamic "filter" {
    # Only apply filter if pool ID isn't directly specified
    for_each = var.ipam_workload_pool_id == "" ? [1] : []
    content {
      name   = "tag:Name"
      values = ["${var.ipam_name}-workload-pool"]
    }
  }
}
