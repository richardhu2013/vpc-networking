
transit_account_role_arn  = "arn:aws:iam::681696216801:role/DEVTerraformDeploymentRole"
workload_account_role_arn = "arn:aws:iam::248896117066:role/DEVTerraformDeploymentRole"
transit_gateway_id        = "tgw-010d2c2b785879692"
management_cidrs          = ["10.0.0.0/8", "172.16.0.0/12"]
cisco_vpc_netmask_length  = 24
use_ipam                  = true
enable_vpc_flow_logs      = true
availability_zones        = ["ap-southeast-4a", "ap-southeast-4b"]
cisco_vpcs = {
  guest = {
    name                         = "cisco-guest"
    description                  = "Cisco ISE Guest VPC with public-facing PSN components"
    cidr                         = "10.0.32.0/24"
    use_specific_cidr            = true
    create_nat_gateways          = true
    create_network_load_balancer = true
    lambda_enabled               = true
  },
  non-guest = {
    name                         = "cisco-non-guest"
    description                  = "Cisco ISE Non-Guest VPC with internal PSN components"
    cidr                         = "10.0.33.0/24"
    use_specific_cidr            = true
    create_nat_gateways          = true
    create_network_load_balancer = true
    lambda_enabled               = true
  }
}