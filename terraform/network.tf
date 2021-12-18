# VPC
resource "aws_vpc" "main" {
  cidr_block = "15.23.0.0/16"

  tags = {
    Name = "main"
  }
}

# IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# Route table
resource "aws_route_table" "web" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "web"
  }
}

resource "aws_route_table" "elk" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "elk"
  }
}

# Public subnet
resource "aws_subnet" "web" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "15.23.1.0/24"

  tags = {
    Name = "Web (Private) Subnet"
  }
}

# Private subnet (cause only I have access to it)
resource "aws_subnet" "elk" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "15.23.3.0/24"

  tags = {
    Name = "ELK (Public) Subnet"
  }
}

# RTA
resource "aws_route_table_association" "rta-web" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.web.id
}

resource "aws_route_table_association" "rta-elk" {
  subnet_id      = aws_subnet.elk.id
  route_table_id = aws_route_table.elk.id
}

# Add aws route for nat-gateway and igw
resource "aws_route" "r-igw" {
  route_table_id = aws_route_table.elk.id
  # have a look at this bit
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id

  depends_on = [aws_route_table.elk]
}

resource "aws_route" "r-nat-gateway" {
  route_table_id = aws_route_table.web.id
  # have a look at this bit
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id

  depends_on = [aws_route_table.web]
}

# NAT Gateway And EIPs here
resource "aws_eip" "nat-elk" {
  # associate instance running elk
  instance = aws_instance.elk.id
  tags = {
    Name = "ELK"
  }
}

resource "aws_eip" "nat-web" {
  tags = {
    Name = "Web"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat-web.id
  subnet_id     = aws_subnet.web.id

  depends_on = [aws_internet_gateway.gw]
}
