variable "vpc_id" {
  description = "VPC ID where subnets will be created"
  type        = string
}

variable "subnet_type" {
  description = "Type of subnet (e.g., tgw-attachment, application, data)"
  type        = string
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones where subnets will be created"
  type        = list(string)
}

variable "route_table_routes" {
  description = "List of route configurations for route tables"
  type = list(object({
    cidr_block = string
    gateway_id = string
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "Name of the VPC (used for naming resources)"
  type        = string
}