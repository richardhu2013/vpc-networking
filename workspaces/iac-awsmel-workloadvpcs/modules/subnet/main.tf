/**
 * # Subnet Module
 * This module creates a set of subnets across availability zones with associated route tables.
 */
resource "aws_subnet" "this" {
  count = length(var.subnet_cidrs)

  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(
    {
      Name = "${var.vpc_name}-${var.subnet_type}-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table" "this" {
  count = length(var.subnet_cidrs)
  
  vpc_id = var.vpc_id
  
  tags = merge(
    {
      Name = "${var.vpc_name}-${var.subnet_type}-rt-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "this" {
  count = length(var.subnet_cidrs)
  
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.this[count.index].id
}

resource "aws_route" "this" {
  count = length(var.subnet_cidrs) * length(var.route_table_routes)
  
  route_table_id         = aws_route_table.this[floor(count.index / length(var.route_table_routes))].id
  destination_cidr_block = var.route_table_routes[count.index % length(var.route_table_routes)].cidr_block
  transit_gateway_id             = var.route_table_routes[count.index % length(var.route_table_routes)].gateway_id
}

resource "aws_network_acl" "this" {
  vpc_id = var.vpc_id
  subnet_ids = aws_subnet.this[*].id
  
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  
  tags = merge(
    {
      Name = "${var.vpc_name}-${var.subnet_type}-nacl"
    },
    var.tags
  )
}