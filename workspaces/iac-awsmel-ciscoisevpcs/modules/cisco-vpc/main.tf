/**
 * # Cisco VPC Module
 * This module creates a Cisco VPC (Guest or Non-Guest) for ISE components.
 */

# Create the VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Create Internet Gateway (for Guest VPC only)
resource "aws_internet_gateway" "this" {
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-igw"
    },
    var.tags
  )
}

# Create TGW attachment subnets
resource "aws_subnet" "tgw_attachment" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.name}-tgw-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

# Create public subnets (for Guest VPC only)
resource "aws_subnet" "public" {
  count = var.public_subnets_enabled ? length(var.availability_zones) : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, count.index + 2)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.name}-public-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

# Create private subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index + 4)
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.name}-private-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

# Create public route table (for Guest VPC only)
resource "aws_route_table" "public" {
  count = var.public_subnets_enabled ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-public-rt"
    },
    var.tags
  )
}

# Add route to Internet Gateway in public route table (for Guest VPC only)
resource "aws_route" "public_igw" {
  count = var.public_subnets_enabled && var.create_internet_gateway ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

# Associate public subnets with public route table (for Guest VPC only)
resource "aws_route_table_association" "public" {
  count = var.public_subnets_enabled ? length(var.availability_zones) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Create private route tables
resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-private-rt-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Create TGW attachment route table
resource "aws_route_table" "tgw_attachment" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-tgw-rt"
    },
    var.tags
  )
}

# Associate TGW attachment subnets with TGW attachment route table
resource "aws_route_table_association" "tgw_attachment" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.tgw_attachment[count.index].id
  route_table_id = aws_route_table.tgw_attachment.id
}

# Create NAT Gateways (if enabled)
resource "aws_eip" "nat" {
  count  = var.create_nat_gateways ? length(var.availability_zones) : 0
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.name}-nat-eip-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateways ? length(var.availability_zones) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnets_enabled ? aws_subnet.public[count.index].id : aws_subnet.tgw_attachment[count.index].id

  tags = merge(
    {
      Name = "${var.name}-natgw-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

# Add default route to NAT Gateway in private route tables (if NAT Gateways are enabled)
resource "aws_route" "private_natgw" {
  count = var.create_nat_gateways ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

# Add default route to Transit Gateway in private route tables (if NAT Gateways are not enabled)
resource "aws_route" "private_tgw" {
  count = var.create_nat_gateways ? 0 : length(var.availability_zones)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.this.transit_gateway_id
}

# Create Transit Gateway attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids         = aws_subnet.tgw_attachment[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.this.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    {
      Name = "${var.name}-tgw-attachment"
    },
    var.tags
  )
}

# Accept attachment in transit account
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]

  provider = aws.transit_account

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.this.id # or directly use the attachment ID if known

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.name}-tgw-attachment-accepter"
    # Add any other tags as needed
  }
}

# Associate with appropriate Transit Gateway route table
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  depends_on                     = [aws_ec2_transit_gateway_vpc_attachment_accepter.this]
  provider                       = aws.transit_account
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

# Create security groups
resource "aws_security_group" "psn" {
  name        = "${var.name}-psn-sg"
  description = "Security group for PSN components"
  vpc_id      = aws_vpc.this.id

  # Allow internal communication between PSN instances
  ingress {
    description = "Allow communication between PSN instances"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Allow RADIUS authentication traffic
  ingress {
    description = "RADIUS authentication"
    from_port   = 1812
    to_port     = 1813
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.vpc_type == "guest" ? ["0.0.0.0/0"] : var.management_cidrs
  }

  # Allow management access
  ingress {
    description = "Management access"
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
      Name = "${var.name}-psn-sg"
    },
    var.tags
  )
}

resource "aws_security_group" "pan" {
  name        = "${var.name}-pan-sg"
  description = "Security group for PAN components"
  vpc_id      = aws_vpc.this.id

  # Allow traffic from PSN security group
  ingress {
    description     = "Allow traffic from PSN"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.psn.id]
  }

  # Allow management access
  ingress {
    description = "Management access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.management_cidrs
  }

  # Allow HTTPS for management
  ingress {
    description = "HTTPS for management"
    from_port   = 443
    to_port     = 443
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
      Name = "${var.name}-pan-sg"
    },
    var.tags
  )
}

resource "aws_security_group" "mnt" {
  name        = "${var.name}-mnt-sg"
  description = "Security group for MnT components"
  vpc_id      = aws_vpc.this.id

  # Allow traffic from PSN security group
  ingress {
    description     = "Allow traffic from PSN"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.psn.id]
  }

  # Allow traffic from PAN security group
  ingress {
    description     = "Allow traffic from PAN"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.pan.id]
  }

  # Allow management access
  ingress {
    description = "Management access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.management_cidrs
  }

  # Allow HTTPS for management
  ingress {
    description = "HTTPS for management"
    from_port   = 443
    to_port     = 443
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
      Name = "${var.name}-mnt-sg"
    },
    var.tags
  )
}

# Create Network Load Balancer for RADIUS traffic
resource "aws_lb" "radius" {
  count = var.create_network_load_balancer ? 1 : 0

  name               = "${var.name}-radius-nlb"
  internal           = var.nlb_internal
  load_balancer_type = "network"
  subnets            = var.nlb_internal || !var.public_subnets_enabled ? aws_subnet.private[*].id : aws_subnet.public[*].id

  enable_cross_zone_load_balancing = true

  tags = merge(
    {
      Name = "${var.name}-radius-nlb"
    },
    var.tags
  )
}

resource "aws_lb_target_group" "radius_auth" {
  count = var.create_network_load_balancer ? 1 : 0

  name     = "${var.name}-radius-auth-tg"
  port     = 1812
  protocol = "UDP"
  vpc_id   = aws_vpc.this.id

  health_check {
    port     = 443
    protocol = "TCP"
    interval = 30
  }

  tags = merge(
    {
      Name = "${var.name}-radius-auth-tg"
    },
    var.tags
  )
}

resource "aws_lb_target_group" "radius_acct" {
  count = var.create_network_load_balancer ? 1 : 0

  name     = "${var.name}-radius-acct-tg"
  port     = 1813
  protocol = "UDP"
  vpc_id   = aws_vpc.this.id

  health_check {
    port     = 443
    protocol = "TCP"
    interval = 30
  }

  tags = merge(
    {
      Name = "${var.name}-radius-acct-tg"
    },
    var.tags
  )
}

resource "aws_lb_listener" "radius_auth" {
  count = var.create_network_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.radius[0].arn
  port              = 1812
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.radius_auth[0].arn
  }
}

resource "aws_lb_listener" "radius_acct" {
  count = var.create_network_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.radius[0].arn
  port              = 1813
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.radius_acct[0].arn
  }
}

# Create Lambda function for Cisco ISE (if enabled)
resource "aws_iam_role" "lambda" {
  count = var.lambda_enabled ? 1 : 0

  name = "${var.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.name}-lambda-role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy" "lambda" {
  count = var.lambda_enabled ? 1 : 0

  name = "${var.name}-lambda-policy"
  role = aws_iam_role.lambda[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterface",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "cisco_handler" {
  count = var.lambda_enabled ? 1 : 0

  function_name = "${var.name}-cisco-handler"
  role          = aws_iam_role.lambda[0].arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 300
  memory_size   = 256

  # Placeholder code - replace with actual implementation
  filename = "${path.module}/lambda/function.zip"

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda[0].id]
  }

  tags = merge(
    {
      Name = "${var.name}-cisco-handler"
    },
    var.tags
  )
}

resource "aws_security_group" "lambda" {
  count = var.lambda_enabled ? 1 : 0

  name        = "${var.name}-lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.name}-lambda-sg"
    },
    var.tags
  )
}

# VPC Flow Logs
resource "aws_flow_log" "this" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  iam_role_arn    = var.flow_log_role_arn
  log_destination = var.flow_log_destination_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-flow-log"
    },
    var.tags
  )
}

# Placeholder for the lambda code zip file
resource "local_file" "lambda_zip" {
  count = var.lambda_enabled ? 1 : 0

  content  = <<-EOF
    exports.handler = async (event) => {
      console.log('Cisco ISE handler invoked');
      return {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda!'),
      };
    };
  EOF
  filename = "${path.module}/lambda/index.js"
}

data "archive_file" "lambda_package" {
  count = var.lambda_enabled ? 1 : 0

  type        = "zip"
  source_file = local_file.lambda_zip[0].filename
  output_path = "${path.module}/lambda/function.zip"
}
