/**
 * # IPAM Module
 * This module creates AWS IPAM resources with pools and resource sharing.
 */
 
# Create the IPAM
resource "aws_vpc_ipam" "this" {
  description = var.description
  operating_regions {
    region_name = var.primary_region
  }
  
  dynamic "operating_regions" {
    for_each = var.additional_regions
    content {
      region_name = operating_regions.value
    }
  }
  
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Create the top-level IPAM pool
resource "aws_vpc_ipam_pool" "top_level" {
  description       = "Top-level IPAM pool for ${var.primary_region}"
  address_family    = var.address_family
  ipam_scope_id     = aws_vpc_ipam.this.private_default_scope_id
  locale            = var.primary_region
  
  tags = merge(
    {
      Name = "${var.name}-top-level-pool"
    },
    var.tags
  )
}

# Provision CIDR to the top-level pool
resource "aws_vpc_ipam_pool_cidr" "top_level" {
  ipam_pool_id = aws_vpc_ipam_pool.top_level.id
  cidr         = var.top_level_cidr
}

# Create the regional pool under the top-level pool
resource "aws_vpc_ipam_pool" "regional" {
  description          = "Regional pool for ${var.primary_region}"
  address_family       = var.address_family
  ipam_scope_id        = aws_vpc_ipam.this.private_default_scope_id
  locale               = var.primary_region
  source_ipam_pool_id  = aws_vpc_ipam_pool.top_level.id
  
  tags = merge(
    {
      Name = "${var.name}-regional-pool"
    },
    var.tags
  )
}

# Provision CIDR to the regional pool
resource "aws_vpc_ipam_pool_cidr" "regional" {
  ipam_pool_id   = aws_vpc_ipam_pool.regional.id
  cidr           = var.regional_cidr
}

# Create functional pools for each type of VPC
resource "aws_vpc_ipam_pool" "functional_pools" {
  for_each = var.functional_pools
  
  description          = "Pool for ${each.key} VPCs in ${var.primary_region}"
  address_family       = var.address_family
  ipam_scope_id        = aws_vpc_ipam.this.private_default_scope_id
  locale               = var.primary_region
  source_ipam_pool_id  = aws_vpc_ipam_pool.regional.id
  
  tags = merge(
    {
      Name = "${var.name}-${each.key}-pool"
    },
    var.tags
  )
}

# Provision CIDRs to the functional pools
resource "aws_vpc_ipam_pool_cidr" "functional_pools" {
  for_each = var.functional_pools
  
  ipam_pool_id   = aws_vpc_ipam_pool.functional_pools[each.key].id
  cidr           = each.value.cidr
}

# Create RAM share for IPAM pools if sharing is enabled
resource "aws_ram_resource_share" "ipam_share" {
  count = var.enable_ram_sharing ? 1 : 0
  
  name                      = "${var.name}-ipam-share"
  allow_external_principals = var.allow_external_principals
  
  tags = merge(
    {
      Name = "${var.name}-ipam-share"
    },
    var.tags
  )
}

# Share the top-level pool
resource "aws_ram_resource_association" "top_level_pool" {
  count = var.enable_ram_sharing ? 1 : 0
  
  resource_arn       = aws_vpc_ipam_pool.top_level.arn
  resource_share_arn = aws_ram_resource_share.ipam_share[0].arn
}

# Share the regional pool
resource "aws_ram_resource_association" "regional_pool" {
  count = var.enable_ram_sharing ? 1 : 0
  
  resource_arn       = aws_vpc_ipam_pool.regional.arn
  resource_share_arn = aws_ram_resource_share.ipam_share[0].arn
}

# Share the functional pools
resource "aws_ram_resource_association" "functional_pools" {
  for_each = var.enable_ram_sharing ? var.functional_pools : {}
  
  resource_arn       = aws_vpc_ipam_pool.functional_pools[each.key].arn
  resource_share_arn = aws_ram_resource_share.ipam_share[0].arn
}

# Associate RAM principals
resource "aws_ram_principal_association" "ipam_principal_association" {
  count = var.enable_ram_sharing ? length(var.principal_account_ids) : 0
  
  principal          = var.principal_account_ids[count.index]
  resource_share_arn = aws_ram_resource_share.ipam_share[0].arn
}