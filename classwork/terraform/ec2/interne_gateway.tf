

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "web" {
  vpc_id = aws_vpc.web.id
  tags = {
    Name = "${var.name}-IGW"
  }
}