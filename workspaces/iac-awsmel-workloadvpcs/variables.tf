# variable "app1_vpc_cidr" {
#   description = "CIDR block for App1 VPC"
#   type        = string
#   default     = "10.100.4.0/24"
# }

# variable "app2_vpc_cidr" {
#   description = "CIDR block for App2 VPC"
#   type        = string
#   default     = "10.100.5.0/24"
# }

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["ap-southeast-4a", "ap-southeast-4b"]
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
}

variable "enable_ssm_endpoints" {
  description = "Whether to enable SSM endpoints in VPCs"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_role_arn" {
  description = "ARN of IAM role for VPC Flow Logs"
  type        = string
  default     = ""
}

variable "flow_log_destination_arn" {
  description = "ARN of the destination for VPC Flow Logs"
  type        = string
  default     = ""
}

variable "use_ipam" {
  description = "Whether to use IPAM for CIDR allocation"
  type        = bool
  default     = false
}

variable "f5_lb_cidrs" {
  description = "CIDR blocks of F5 load balancers"
  type        = list(string)
  default     = ["10.100.2.0/23", "10.100.6.0/23"] # External and Internal LB VPCs
}

variable "management_cidrs" {
  description = "CIDR blocks for management access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "DOEVic-Melbourne"
    ManagedBy   = "Terraform"
  }
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-southeast-4"
}

variable "ipam_workload_pool_id" {
  description = "ID of shared IPAM workload IPs"
  type        = string
  default     = ""
}

# variable "app1_name" {
#   description = "Name of the App 1 VPC"
#   type        = string
# }

variable "ipam_name" {
  description = "Name of the IPAM"
  type        = string
  default     = "de-vic-ipam"
}

variable "vpc_configs" {
  description = "Map of VPC configurations"
  type = map(object({
    name           = string
    use_ipam       = bool
    cidr           = string
    provider_alias = string
  }))
}