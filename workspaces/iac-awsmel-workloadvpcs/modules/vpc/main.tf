/**
 * # VPC Module
 * This module creates a standardized VPC infrastructure without creating subnets.
 * The subnet resources are created separately by the parent module.
 */
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-default-sg"
    },
    var.tags
  )
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = merge(
    {
      Name = "${var.vpc_name}-default-rt"
    },
    var.tags
  )
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  tags = merge(
    {
      Name = "${var.vpc_name}-default-nacl"
    },
    var.tags
  )
}

# Create Transit Gateway attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids         = var.tgw_attachment_subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.this.id
  
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  tags = merge(
    {
      Name = "${var.vpc_name}-tgw-attachment"
    },
    var.tags
  )
}

# Associate with spoke VPC route table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_spoke_route_table_id
}

# Propagate routes to other relevant route tables
resource "aws_ec2_transit_gateway_route_table_propagation" "security_vpc_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_security_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "external_lb_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_external_lb_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "internal_lb_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_internal_lb_route_table_id
}

# # VPC Endpoint for SSM services if needed
# resource "aws_vpc_endpoint" "ssm" {
#   count = var.create_ssm_endpoints ? 1 : 0
  
#   vpc_id            = aws_vpc.this.id
#   service_name      = "com.amazonaws.${var.aws_region}.ssm"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = var.app_subnet_ids
#   security_group_ids = [
#     aws_security_group.endpoint[0].id
#   ]
#   private_dns_enabled = true
  
#   tags = merge(
#     {
#       Name = "${var.vpc_name}-ssm-endpoint"
#     },
#     var.tags
#   )
# }

# resource "aws_vpc_endpoint" "ssmmessages" {
#   count = var.create_ssm_endpoints ? 1 : 0
  
#   vpc_id            = aws_vpc.this.id
#   service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = var.app_subnet_ids
#   security_group_ids = [
#     aws_security_group.endpoint[0].id
#   ]
#   private_dns_enabled = true
  
#   tags = merge(
#     {
#       Name = "${var.vpc_name}-ssmmessages-endpoint"
#     },
#     var.tags
#   )
# }

# resource "aws_vpc_endpoint" "ec2messages" {
#   count = var.create_ssm_endpoints ? 1 : 0
  
#   vpc_id            = aws_vpc.this.id
#   service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = var.app_subnet_ids
#   security_group_ids = [
#     aws_security_group.endpoint[0].id
#   ]
#   private_dns_enabled = true
  
#   tags = merge(
#     {
#       Name = "${var.vpc_name}-ec2messages-endpoint"
#     },
#     var.tags
#   )
# }

# resource "aws_security_group" "endpoint" {
#   count = var.create_ssm_endpoints ? 1 : 0
  
#   name        = "${var.vpc_name}-endpoint-sg"
#   description = "Security group for VPC Endpoints"
#   vpc_id      = aws_vpc.this.id
  
#   ingress {
#     description = "HTTPS from VPC"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.this.cidr_block]
#   }
  
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  
#   tags = merge(
#     {
#       Name = "${var.vpc_name}-endpoint-sg"
#     },
#     var.tags
#   )
# }

# Flow Logs
resource "aws_flow_log" "this" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  
  iam_role_arn    = var.flow_log_role_arn
  log_destination = var.flow_log_destination_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
  
  tags = merge(
    {
      Name = "${var.vpc_name}-flow-log"
    },
    var.tags
  )
}