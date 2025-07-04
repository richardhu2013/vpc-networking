/**
 * # VPC Module
 * This module creates a standardized VPC infrastructure without creating subnets.
 * The subnet resources are created separately by the parent module.
 */
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.transit_account]
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-default-sg"
    },
    var.tags
  )
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = merge(
    {
      Name = "${var.vpc_name}-default-rt"
    },
    var.tags
  )
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  tags = merge(
    {
      Name = "${var.vpc_name}-default-nacl"
    },
    var.tags
  )
}

# Create Transit Gateway attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids         = var.tgw_attachment_subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.this.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    {
      Name = "${var.vpc_name}-tgw-attachment"
    },
    var.tags
  )
}

# Accept attachment in transit account
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]

  provider = aws.transit_account

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.this.id # or directly use the attachment ID if known

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.vpc_name}-tgw-attachment-accepter"
    # Add any other tags as needed
  }
}

# Associate with spoke VPC route table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_rt_association" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.this]

  provider                       = aws.transit_account
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_spoke_route_table_id
}

# Propagate routes to other relevant route tables
resource "aws_ec2_transit_gateway_route_table_propagation" "security_vpc_rt_propagation" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.this]

  provider                       = aws.transit_account
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_security_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "external_lb_rt_propagation" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.this]

  provider                       = aws.transit_account
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_external_lb_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "internal_lb_rt_propagation" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.this]

  provider                       = aws.transit_account
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_internal_lb_route_table_id
}

# Flow Logs
resource "aws_flow_log" "this" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  iam_role_arn    = var.flow_log_role_arn
  log_destination = var.flow_log_destination_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-flow-log"
    },
    var.tags
  )
}
