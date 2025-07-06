/**
 * # Transit Gateway Module
 * This module creates a Transit Gateway with optional Direct Connect Gateway attachment.
 */

resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Create default route table for the Transit Gateway
resource "aws_ec2_transit_gateway_route_table" "default" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(
    {
      Name = "${var.name}-default-rt"
    },
    var.tags
  )
}

# Create Direct Connect Gateway attachment if enabled
resource "aws_dx_gateway" "this" {
  count = var.enable_dx_gateway ? 1 : 0

  name            = "${var.name}-dxgw"
  amazon_side_asn = var.dx_amazon_side_asn
}

resource "aws_dx_gateway_association" "this" {
  count = var.enable_dx_gateway ? 1 : 0

  dx_gateway_id         = aws_dx_gateway.this[0].id
  associated_gateway_id = aws_ec2_transit_gateway.this.id

  allowed_prefixes = var.dx_allowed_prefixes
}

# VPC and VPN attachments are handled outside this module
# as they are typically managed in the respective VPC modules