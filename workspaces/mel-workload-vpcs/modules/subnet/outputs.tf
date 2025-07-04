output "subnet_ids" {
  description = "List of IDs of the created subnets"
  value       = aws_subnet.this[*].id
}

output "subnet_cidrs" {
  description = "List of CIDR blocks of the created subnets"
  value       = aws_subnet.this[*].cidr_block
}

output "route_table_ids" {
  description = "List of IDs of the route tables created"
  value       = aws_route_table.this[*].id
}

output "network_acl_id" {
  description = "ID of the network ACL created"
  value       = aws_network_acl.this.id
}