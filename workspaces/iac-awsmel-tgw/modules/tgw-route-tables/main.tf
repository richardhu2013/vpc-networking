/**
 * # Transit Gateway Route Tables Module
 * This module creates a set of Transit Gateway route tables with appropriate routes.
 */
 
# Create route tables
resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = { for rt in var.route_tables : rt.name => rt }
  
  transit_gateway_id = var.transit_gateway_id
  
  tags = merge(
    {
      Name = each.value.name
    },
    var.tags
  )
}

# Create static routes
resource "aws_ec2_transit_gateway_route" "routes" {
  for_each = {
    for idx, route in var.static_routes : 
    "${route.route_table_name}-${route.destination_cidr_block}" => route
  }
  
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_name].id
  blackhole                      = try(each.value.blackhole, null)
}

# # Default route to Security VPC for all VPCs except Cisco VPCs
# resource "aws_ec2_transit_gateway_route" "default_route_to_security" {
#   for_each = {
#     for name, rt in aws_ec2_transit_gateway_route_table.this :
#     name => rt if contains(var.default_route_to_security_vpc_route_tables, name)
#   }
  
#   destination_cidr_block         = "0.0.0.0/0"
#   transit_gateway_attachment_id  = var.security_vpc_attachment_id
#   transit_gateway_route_table_id = each.value.id
# }

# Create route table associations
resource "aws_ec2_transit_gateway_route_table_association" "associations" {
  for_each = {
    for idx, assoc in var.route_table_associations :
    "${assoc.route_table_name}-${assoc.transit_gateway_attachment_id}" => assoc
  }
  
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_name].id
}

# Create route table propagations
resource "aws_ec2_transit_gateway_route_table_propagation" "propagations" {
  for_each = {
    for idx, prop in var.route_table_propagations :
    "${prop.route_table_name}-${prop.transit_gateway_attachment_id}" => prop
  }
  
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_name].id
}