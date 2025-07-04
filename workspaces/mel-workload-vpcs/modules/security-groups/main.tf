/**
 * # Security Groups Module
 * This module creates standardized security groups for workload VPCs.
 */

resource "aws_security_group" "app_tier" {
  name        = "${var.vpc_name}-app-tier-sg"
  description = "Security group for application tier"
  vpc_id      = var.vpc_id

  # Allow internal communication between app instances
  ingress {
    description = "Allow communication between app instances"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  
  # Allow inbound from F5
  ingress {
    description     = "Allow traffic from F5 load balancers"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = var.f5_lb_cidrs
  }
  
  ingress {
    description     = "Allow HTTPS from F5 load balancers"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = var.f5_lb_cidrs
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-app-tier-sg"
    },
    var.tags
  )
}

resource "aws_security_group" "data_tier" {
  name        = "${var.vpc_name}-data-tier-sg"
  description = "Security group for data tier"
  vpc_id      = var.vpc_id

  # Allow access from app tier only
  ingress {
    description     = "Allow access from app tier"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.app_tier.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-data-tier-sg"
    },
    var.tags
  )
}

resource "aws_security_group" "management" {
  name        = "${var.vpc_name}-management-sg"
  description = "Security group for management access"
  vpc_id      = var.vpc_id

  # Allow SSH from management networks
  ingress {
    description = "SSH from management networks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.management_cidrs
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-management-sg"
    },
    var.tags
  )
}