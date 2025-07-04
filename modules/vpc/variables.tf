variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "tgw_attachment_subnet_ids" {
  description = "List of subnet IDs to use for Transit Gateway attachment"
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach to"
  type        = string
}

variable "transit_gateway_spoke_route_table_id" {
  description = "ID of the spoke VPC Transit Gateway route table"
  type        = string
}

variable "transit_gateway_security_route_table_id" {
  description = "ID of the Security VPC Transit Gateway route table"
  type        = string
}

variable "transit_gateway_external_lb_route_table_id" {
  description = "ID of the External LB VPC Transit Gateway route table"
  type        = string
}

variable "transit_gateway_internal_lb_route_table_id" {
  description = "ID of the Internal LB VPC Transit Gateway route table"
  type        = string
}

variable "create_ssm_endpoints" {
  description = "Whether to create SSM VPC endpoints"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-southeast-4"
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

variable "app_subnet_ids" {
  description = "List of subnet IDs for application subnets (used for VPC endpoints)"
  type        = list(string)
  default     = []
}