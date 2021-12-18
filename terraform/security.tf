# NACLs for subnets


# Security groups for ASG and ELK instance
resource "aws_security_group" "elk" {
  name = "elk-access"
  description = "Allow SSH access, and allow interaction with other instances"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
# change this to dynamically use my ip
    cidr_block =["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
# change this to dynamically use my ip
    cidr_block =["0.0.0.0/0"]
  }

# allow beats access, double check if this is the correct port
  ingress {
    from_port = 5200
    to_port = 5200
    protocol = "tcp"
# allow from the web subnet
    cidr_block =[aws_subnet.web.cidr_block]
  }

  egress {
    from_port = 0
    to_port= 0
# all protocols allowed out
    protocol = "-1"
    cidr_block =["0.0.0.0/0"]
  }
}

