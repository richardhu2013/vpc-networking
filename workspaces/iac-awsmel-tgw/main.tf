/**
 * # Melbourne Region Transit Gateway
 * This workspace creates the central Transit Gateway for the Department of Education Victoria's
 * Melbourne region deployment, including all necessary route tables and configurations.
 */

# Create the Transit Gateway
module "transit_gateway" {
  source = "./modules/transit-gateway"

  name            = var.transit_gateway_name
  description     = var.transit_gateway_description
  amazon_side_asn = var.transit_gateway_asn

  # Direct Connect integration
  enable_dx_gateway   = var.enable_dx_gateway
  dx_amazon_side_asn  = var.dx_amazon_side_asn
  dx_allowed_prefixes = var.dx_allowed_prefixes

  tags = var.tags
}

# Create route tables only after Transit Gateway is available
module "route_tables" {
  source     = "./modules/tgw-route-tables"
  depends_on = [module.transit_gateway]

  transit_gateway_id = module.transit_gateway.transit_gateway_id

  # Create the seven route tables required for the Melbourne region
  route_tables = [
    {
      name        = "spoke_vpc_tgw_att_RT"
      description = "Route table for standard workload VPCs"
    },
    {
      name        = "sec-vpc-tgw-att-RT"
      description = "Route table for Security VPC"
    },
    {
      name        = "ext-lb-vpc-tgw-att-rt"
      description = "Route table for External LB VPC"
    },
    {
      name        = "int-lb-vpc-tgw-att-rt"
      description = "Route table for Internal LB VPC"
    },
    {
      name        = "cisco-guest-vpc-tgw-att-RT"
      description = "Route table for Cisco Guest VPC"
    },
    {
      name        = "cisco-non-guest-vpc-tgw-att-RT"
      description = "Route table for Cisco Non-Guest VPC"
    },
    {
      name        = "onprem-tgw-att-RT"
      description = "Route table for On-Premises connections via Direct Connect"
    }
  ]

  # Static routes will be added when VPC attachments are created
  # We're not defining static routes here as they are typically added when VPCs are attached
  # This would be done in the respective VPC workspaces

  # Default route to Security VPC route tables
  # This applies only to VPCs that need to go through security inspection
  default_route_to_security_vpc_route_tables = [
    "spoke_vpc_tgw_att_RT",
    "ext-lb-vpc-tgw-att-rt",
    "int-lb-vpc-tgw-att-rt"
  ]

  # Security VPC attachment ID will be provided after Security VPC workspace is applied
  # security_vpc_attachment_id = var.security_vpc_attachment_id

  tags = var.tags
}

# RAM Share for Transit Gateway (if cross-account sharing is needed)
resource "aws_ram_resource_share" "tgw_share" {
  count = var.enable_ram_sharing ? 1 : 0

  name                      = "${var.transit_gateway_name}-share"
  allow_external_principals = var.allow_external_principals

  tags = merge(
    var.tags,
    {
      Name = "${var.transit_gateway_name}-share"
    }
  )
}

resource "aws_ram_resource_association" "tgw_association" {
  count = var.enable_ram_sharing ? 1 : 0

  resource_arn       = module.transit_gateway.transit_gateway_arn
  resource_share_arn = aws_ram_resource_share.tgw_share[0].arn
}

resource "aws_ram_principal_association" "account_association" {
  count = var.enable_ram_sharing ? length(var.principal_account_ids) : 0

  principal          = var.principal_account_ids[count.index]
  resource_share_arn = aws_ram_resource_share.tgw_share[0].arn
}

# Create IPAM and address pools for the Melbourne region
module "ipam" {
  source = "./modules/ipam"

  name           = var.ipam_name
  description    = var.ipam_description
  primary_region = var.region

  # Optional additional regions for multi-region deployments
  additional_regions = var.ipam_additional_regions

  # Top-level CIDR block allocation
  top_level_cidr = var.ipam_top_level_cidr

  # Regional CIDR block allocation
  regional_cidr = var.ipam_regional_cidr

  # Functional pools for different VPC types
  functional_pools = var.ipam_functional_pools

  # RAM sharing for multi-account deployments
  enable_ram_sharing        = var.enable_ipam_ram_sharing
  allow_external_principals = var.allow_external_principals
  principal_account_ids     = var.principal_account_ids

  tags = var.tags
}
