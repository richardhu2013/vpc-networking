# Transit Gateway
transit_gateway_id = "tgw-09424b80bd80feedf"

# VPC CIDRs (if not using IPAM)
app1_vpc_cidr = "10.100.4.0/24"
app2_vpc_cidr = "10.100.5.0/24"

# IPAM configuration
use_ipam = true

# Flow Logs
enable_vpc_flow_logs = true
flow_log_role_arn = "arn:aws:iam::248896117066:role/vpc-flow-logs-role"
flow_log_destination_arn = "arn:aws:logs:ap-southeast-4:248896117066:log-group:/aws/vpc/flowlogs"

# Security groups
f5_lb_cidrs = ["10.100.2.0/23", "10.100.6.0/23"]
management_cidrs = ["10.0.0.0/8", "172.16.0.0/12"]
app1_name = "doevic-mel-workload-1"
# Common tags
tags = {
  Environment = "Production"
  Project     = "DOEVic-Melbourne"
  ManagedBy   = "Terraform"
  Owner       = "Network Team"
  CostCenter  = "12345"
}