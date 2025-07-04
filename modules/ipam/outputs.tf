output "ipam_id" {
  description = "ID of the created IPAM"
  value       = aws_vpc_ipam.this.id
}

output "ipam_arn" {
  description = "ARN of the created IPAM"
  value       = aws_vpc_ipam.this.arn
}

output "private_scope_id" {
  description = "ID of the private scope"
  value       = aws_vpc_ipam.this.private_default_scope_id
}

output "top_level_pool_id" {
  description = "ID of the top-level IPAM pool"
  value       = aws_vpc_ipam_pool.top_level.id
}

output "top_level_pool_arn" {
  description = "ARN of the top-level IPAM pool"
  value       = aws_vpc_ipam_pool.top_level.arn
}

output "regional_pool_id" {
  description = "ID of the regional IPAM pool"
  value       = aws_vpc_ipam_pool.regional.id
}

output "functional_pool_ids" {
  description = "Map of functional pool names to their IDs"
  value = {
    for name, pool in aws_vpc_ipam_pool.functional_pools : name => pool.id
  }
}

output "ram_resource_share_arn" {
  description = "ARN of the RAM resource share for IPAM (if created)"
  value       = var.enable_ram_sharing ? aws_ram_resource_share.ipam_share[0].arn : null
}