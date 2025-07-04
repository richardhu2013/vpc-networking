# Transit Gateway Module

This module creates a Transit Gateway for the Department of Education Victoria's Melbourne region deployment. The Transit Gateway serves as the central network hub connecting all VPCs, Direct Connect Gateway, and potentially VPN connections.

## Features

- Transit Gateway creation with configurable settings
- Optional Direct Connect Gateway integration
- Default route table creation
- Support for DNS and VPN ECMP

## Usage

```hcl
module "transit_gateway" {
  source = "../../modules/transit-gateway"

  name           = "de-poc-tgw"
  description    = "Transit Gateway for Melbourne region"
  amazon_side_asn = 64512
  
  # Direct Connect integration
  enable_dx_gateway = true
  dx_amazon_side_asn = 64513
  dx_allowed_prefixes = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  
  tags = {
    Environment = "Production"
    Project     = "DOEVic-Melbourne"
  }
}