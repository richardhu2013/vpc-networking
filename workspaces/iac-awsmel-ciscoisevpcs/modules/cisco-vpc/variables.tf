variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_type" {
  description = "Type of Cisco VPC (guest or non-guest)"
  type        = string
  validation {
    condition     = contains(["guest", "non-guest"], var.vpc_type)
    error_message = "VPC type must be either 'guest' or 'non-guest'."
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

variable "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table to associate with"
  type        = string
}

variable "transit_gateway_security_route_table_id" {
  description = "ID of the Security VPC Transit Gateway route table"
  type        = string
}

variable "public_subnets_enabled" {
  description = "Whether to create public subnets"
  type        = bool
  default     = false
}

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = false
}

variable "create_nat_gateways" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = false
}

variable "create_network_load_balancer" {
  description = "Whether to create a Network Load Balancer"
  type        = bool
  default     = true
}

variable "nlb_internal" {
  description = "Whether the Network Load Balancer should be internal"
  type        = bool
  default     = true
}

variable "lambda_enabled" {
  description = "Whether to enable the Lambda function for Cisco ISE"
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

variable "management_cidrs" {
  description = "CIDR blocks for management access"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-4"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}