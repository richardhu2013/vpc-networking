output "transit_gateway_id" {
  description = "ID of the created Transit Gateway"
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  description = "ARN of the created Transit Gateway"
  value       = aws_ec2_transit_gateway.this.arn
}

output "transit_gateway_default_route_table_id" {
  description = "ID of the default route table"
  value       = aws_ec2_transit_gateway_route_table.default.id
}

output "dx_gateway_id" {
  description = "ID of the Direct Connect Gateway"
  value       = var.enable_dx_gateway ? aws_dx_gateway.this[0].id : null
}