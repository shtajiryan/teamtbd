
variable "private_key_path" {
  type    = string
  default = "~/.ssh/*.pem"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-007855ac798b5175e"
}
variable "name" {
  type    = string
  default = "Test"
}

# Create an EC2 instance
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.web.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name      = "virginia"
  tags = {
    Name = "${var.name}-Instance"
  }
}

output "aws_instance" {
  value = aws_instance.web
}
# "sudo scp -i ./Desktop/pem/virginia.pem ./Desktop/pem/virginia.pem ubuntu@${self.public_dns}:/home/ubuntu"