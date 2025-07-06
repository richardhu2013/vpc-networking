variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
}

variable "route_tables" {
  description = "List of route tables to create"
  type = list(object({
    name        = string
    description = optional(string)
  }))
}

variable "static_routes" {
  description = "List of static routes to create"
  type = list(object({
    route_table_name              = string
    destination_cidr_block        = string
    transit_gateway_attachment_id = string
    blackhole                     = optional(bool)
  }))
  default = []
}

variable "route_table_associations" {
  description = "List of route table associations to create"
  type = list(object({
    route_table_name              = string
    transit_gateway_attachment_id = string
  }))
  default = []
}

variable "route_table_propagations" {
  description = "List of route table propagations to create"
  type = list(object({
    route_table_name              = string
    transit_gateway_attachment_id = string
  }))
  default = []
}

variable "security_vpc_attachment_id" {
  description = "ID of the Security VPC attachment for default routes"
  type        = string
  default     = ""
}

variable "default_route_to_security_vpc_route_tables" {
  description = "List of route table names that should have a default route to the Security VPC"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}