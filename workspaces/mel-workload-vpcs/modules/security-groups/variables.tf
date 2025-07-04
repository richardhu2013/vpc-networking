variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC (used for naming resources)"
  type        = string
}

variable "f5_lb_cidrs" {
  description = "CIDR blocks for F5 load balancers"
  type        = list(string)
}

variable "management_cidrs" {
  description = "CIDR blocks for management access"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}