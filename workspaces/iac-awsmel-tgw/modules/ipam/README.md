# IPAM Module

This module creates an AWS IPAM (IP Address Management) implementation with a hierarchical pool structure for the Department of Education Victoria's Melbourne region deployment. 

## Features

- IPAM creation with multi-region support
- Hierarchical pool structure (top-level, regional, and functional pools)
- Resource Access Manager (RAM) integration for sharing across accounts
- Pool CIDR allocations

## Pool Structure

The module creates a three-tier IPAM pool hierarchy:

1. **Top-level pool** - Contains the entire address space
2. **Regional pool** - Region-specific allocation from the top-level pool
3. **Functional pools** - Purpose-specific allocations for different VPC types:
   - Security VPC pool
   - External LB VPC pool
   - Internal LB VPC pool
   - Workload VPC pool
   - Cisco VPC pool

## Usage

```hcl
module "ipam" {
  source = "../../modules/ipam"

  name           = "de-vic-ipam"
  description    = "IPAM for Department of Education Victoria"
  primary_region = "ap-southeast-4"
  
  # Optional additional regions
  additional_regions = ["ap-southeast-2"]
  
  # Top-level address space
  top_level_cidr = "10.0.0.0/16"
  
  # Regional allocation
  regional_cidr = "10.0.0.0/16"
  
  # Functional pool allocations
  functional_pools = {
    security = {
      cidr        = "10.0.0.0/23"
      description = "Pool for Security VPC"
    },
    external-lb = {
      cidr        = "10.0.2.0/23"
      description = "Pool for External LB VPC"
    },
    internal-lb = {
      cidr        = "10.0.6.0/23"
      description = "Pool for Internal LB VPC"
    },
    workload = {
      cidr        = "10.0.16.0/20"
      description = "Pool for Workload VPCs"
    },
    cisco = {
      cidr        = "10.0.32.0/20"
      description = "Pool for Cisco VPCs"
    }
  }
  
  # Share with other accounts
  enable_ram_sharing = true
  principal_account_ids = ["111111111111", "222222222222"]
  
  tags = {
    Environment = "Production"
    Project     = "DOEVic-Melbourne"
  }
}