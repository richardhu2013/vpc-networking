# VPC Module

This module creates a standardized VPC for workload applications in the Department of Education Victoria's Melbourne region deployment. The VPC follows the three-tier subnet design with:

- Transit Gateway attachment subnets
- Application subnets
- Data subnets

## Features

- Multi-AZ deployment (ap-southeast-4a and ap-southeast-4b)
- Transit Gateway integration with proper route table associations
- Optional VPC endpoints for SSM access
- VPC Flow Logs configuration
- Security groups and NACLs setup

## Usage

```hcl
module "workload_vpc" {
  source = "../../modules/vpc"

  vpc_name   = "app1-vpc"
  vpc_cidr   = "10.100.4.0/24"
  
  # Subnets (one per AZ)
  tgw_subnet_cidrs = ["10.100.4.0/27", "10.100.4.32/27"]
  app_subnet_cidrs = ["10.100.4.128/25", "10.100.4.0/25"]
  data_subnet_cidrs = ["10.100.4.128/25", "10.100.4.0/25"]
  
  # Transit Gateway configuration
  transit_gateway_id = "tgw-0123456789abcdef"
  transit_gateway_spoke_route_table_id = "tgw-rtb-spoke"
  transit_gateway_security_route_table_id = "tgw-rtb-security"
  transit_gateway_external_lb_route_table_id = "tgw-rtb-ext-lb"
  transit_gateway_internal_lb_route_table_id = "tgw-rtb-int-lb"
  
  # Optional features
  create_ssm_endpoints = true
  enable_vpc_flow_logs = true
  flow_log_role_arn = "arn:aws:iam::123456789012:role/vpc-flow-logs-role"
  flow_log_destination_arn = "arn:aws:logs:ap-southeast-4:123456789012:log-group:/aws/vpc/flowlogs"
  
  tags = {
    Environment = "Production"
    Project     = "DOEVic-Melbourne"
    Application = "App1"
  }
}