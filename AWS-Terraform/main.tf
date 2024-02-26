# VPC
resource "aws_vpc" "vpc_demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Demo VPC"
  }
}

# subnet
resource "aws_subnet" "subnet_demo" {
  vpc_id = aws_vpc.vpc_demo.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Demo Public Subnet"
  }
}

resource "aws_internet_gateway" "demo_gw" {
  vpc_id = aws_vpc.vpc_demo.id
 
 tags = {
   Name = "Demo Gateway"
 }
}

resource "aws_route_table" "demo_rtb" {
 vpc_id = aws_vpc.vpc_demo.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.demo_gw.id
 }
 
 tags = {
   Name = "Demo Route Table"
 }
}

resource "aws_route_table_association" "demo_subnet_asso" {
 subnet_id      = aws_subnet.subnet_demo.id
 route_table_id = aws_route_table.demo_rtb.id
}

# EC2 instance
resource "aws_instance" "ec2_demo" {
  ami = "ami-0eb4694aa6f249c52"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_demo.id
  associate_public_ip_address = true

  tags = {
    Name = "Demo EC2"
  }
}