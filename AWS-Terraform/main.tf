# VPC
resource "aws_vpc" "vpc_demo" {
  count = 1
  cidr_block = "10.0.0.0/16"
}

# subnet
resource "aws_subnet" "subnet_demo" {
  count = 1
  vpc_id = aws_vpc.vpc_demo.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "demo_gw" {
  count = 1
 vpc_id = aws_vpc.vpc_demo.id
 
 tags = {
   Name = "Demo Gateway"
 }
}

resource "aws_route_table" "demo_rtb" {
  count = 1
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
 count = 1
 subnet_id      = aws_subnet.subnet_demo.id
 route_table_id = aws_route_table.demo_rtb.id
}

# EC2 instance
resource "aws_instance" "ec2_demo" {
  count = 1
  ami = "ami-0eb4694aa6f249c52"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_demo.id
}