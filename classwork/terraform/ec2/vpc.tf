
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Create a VPC
resource "aws_vpc" "web" {
  cidr_block = var.vpc_cidr
  # Enable DNS support for the VPC
  enable_dns_support = true

  # Enable auto-assign public IP addresses for instances launched in this VPC
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-VPC"
  }
}