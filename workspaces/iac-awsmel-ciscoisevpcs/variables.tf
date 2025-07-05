variable "cisco_vpcs" {
  description = "Map of Cisco VPCs to create with their configurations"
  type = map(any)
  default = {
    guest = {
      name = "cisco-guest"
      description = "Cisco ISE Guest VPC with public-facing PSN components"
      cidr = "10.0.32.0/24"
      use_specific_cidr = true
      create_nat_gateways = true
      create_network_load_balancer = true
      lambda_enabled = true
    },
    non-guest = {
      name = "cisco-non-guest"
      description = "Cisco ISE Non-Guest VPC with internal PSN components"
      cidr = "10.0.33.0/24"
      use_specific_cidr = true
      create_nat_gateways = true
      create_network_load_balancer = true
      lambda_enabled = true
    }
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["ap-southeast-4a", "ap-southeast-4b"]
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
}

variable "enable_vpc_flow_logs" {
  description = "Whether to enable VPC Flow Logs by default"
  type        = bool
  default     = true
}

variable "flow_log_role_arn" {
  description = "ARN of IAM role for VPC Flow Logs (if created externally)"
  type        = string
  default     = ""
}

variable "flow_log_destination_arn" {
  description = "ARN of the destination for VPC Flow Logs (if created externally)"
  type        = string
  default     = ""
}

variable "use_ipam" {
  description = "Whether to use IPAM for CIDR allocation"
  type        = bool
  default     = true
}

variable "ipam_cisco_pool_id" {
  description = "ID of the IPAM pool for Cisco VPCs"
  type        = string
  default     = ""
}

variable "ipam_name" {
  description = "Name of the IPAM (used to find pool if ID not provided)"
  type        = string
  default     = "de-vic-ipam"
}

variable "cisco_vpc_netmask_length" {
  description = "Netmask length for Cisco VPC CIDR allocations from IPAM"
  type        = number
  default     = 24
}

variable "management_cidrs" {
  description = "CIDR blocks for management access"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12"]
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-4"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    Project     = "DOEVic-Melbourne"
    ManagedBy   = "Terraform"
    Owner       = "Network Team"
    CostCenter  = "12345"
  }
}