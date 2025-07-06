# Transit Gateway
transit_gateway_id = "tgw-010d2c2b785879692"

# VPC CIDRs (if not using IPAM)
# app1_vpc_cidr = "10.100.4.0/24"
# app2_vpc_cidr = "10.100.5.0/24"

# IPAM configuration
use_ipam = true

# Flow Logs
enable_vpc_flow_logs = true
#flow_log_role_arn = "arn:aws:iam::248896117066:role/vpc-flow-logs-role"
#flow_log_destination_arn = "arn:aws:logs:ap-southeast-4:248896117066:log-group:/aws/vpc/flowlogs"

# Security groups
f5_lb_cidrs      = ["10.100.2.0/23", "10.100.6.0/23"]
management_cidrs = ["10.0.0.0/8", "172.16.0.0/12"]
# app1_name        = "doevic-mel-workload-1"
# Common tags
tags = {
  Environment = "Production"
  Project     = "DOEVic-Melbourne"
  ManagedBy   = "Terraform"
  Owner       = "Network Team"
  CostCenter  = "12345"
}

vpc_configs = {
  app1 = {
    name           = "doevic-mel-workload-1"
    use_ipam       = true
    cidr           = "10.100.16.0/24" # only used if use_ipam = false
    provider_alias = "app1_account"
  }

  app2 = {
    name           = "doevic-mel-workload-1"
    use_ipam       = false
    cidr           = "10.100.32.0/24"
    provider_alias = "app2_account"
  }
}
