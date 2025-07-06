# Transit Gateway configuration
transit_gateway_name        = "dev-vic-mel-tgw"
transit_gateway_description = "Transit Gateway for Melbourne region (ap-southeast-4)"
transit_gateway_asn         = 64512

# Direct Connect Gateway configuration
enable_dx_gateway   = false
dx_amazon_side_asn  = 64513
dx_allowed_prefixes = ["10.100.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

# RAM Sharing (for multi-account setup)
enable_ram_sharing        = true
allow_external_principals = false
principal_account_ids = [
  "248896117066"
  # Application account
]

# IPAM Configuration
ipam_name               = "de-vic-ipam"
ipam_description        = "IPAM for Department of Education Victoria Melbourne region"
ipam_additional_regions = []
ipam_top_level_cidr     = "10.100.0.0/16"
ipam_regional_cidr      = "10.100.0.0/16"

# Functional IPAM Pools
ipam_functional_pools = {
  security = {
    cidr        = "10.100.0.0/23"
    description = "Pool for Security VPC with Palo Alto Firewalls"
  },
  external-lb = {
    cidr        = "10.100.2.0/23"
    description = "Pool for External LB VPC with F5 load balancers"
  },
  internal-lb = {
    cidr        = "10.100.6.0/23"
    description = "Pool for Internal LB VPC with F5 load balancers"
  },
  workload = {
    cidr        = "10.100.16.0/20"
    description = "Pool for standard Workload VPCs"
  },
  cisco = {
    cidr        = "10.100.32.0/20"
    description = "Pool for Cisco Guest and Non-Guest VPCs"
  }
}

enable_ipam_ram_sharing = true

# Tags
tags = {
  Environment = "Production"
  Project     = "DOEVic-Melbourne"
  ManagedBy   = "Terraform"
  Owner       = "Network Team"
  CostCenter  = "12345"
}