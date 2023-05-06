
variable "route_cidr" {
  type = string
  default = "0.0.0.0/0"
}

# Create a route table for the VPC and add a route to the internet gateway
resource "aws_route_table" "web" {
  vpc_id = aws_vpc.web.id

  route {
    cidr_block = var.route_cidr
    gateway_id = aws_internet_gateway.web.id
  }
  tags = {
    Name = "${var.name}-RT"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.web.id
}