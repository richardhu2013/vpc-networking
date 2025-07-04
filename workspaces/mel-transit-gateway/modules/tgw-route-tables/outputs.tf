output "route_table_ids" {
  description = "Map of route table name to ID"
  value = {
    for name, rt in aws_ec2_transit_gateway_route_table.this : name => rt.id
  }
}

output "route_tables" {
  description = "Map of route table resources"
  value = aws_ec2_transit_gateway_route_table.this
}

output "routes" {
  description = "Map of routes created"
  value = aws_ec2_transit_gateway_route.routes
}

output "associations" {
  description = "Map of route table associations created"
  value = aws_ec2_transit_gateway_route_table_association.associations
}

output "propagations" {
  description = "Map of route table propagations created"
  value = aws_ec2_transit_gateway_route_table_propagation.propagations
}