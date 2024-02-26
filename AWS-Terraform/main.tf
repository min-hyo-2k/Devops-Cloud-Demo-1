# VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Demo VPC"
  }
}

# subnet
resource "aws_subnet" "demo_subnet" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Demo Public Subnet"
  }
}

resource "aws_internet_gateway" "demo_gw" {
  vpc_id = aws_vpc.demo_vpc.id
 
 tags = {
   Name = "Demo Gateway"
 }
}

resource "aws_route_table" "demo_rtb" {
 vpc_id = aws_vpc.demo_vpc.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.demo_gw.id
 }
 
 tags = {
   Name = "Demo Route Table"
 }
}

resource "aws_route_table_association" "demo_subnet_asso" {
 subnet_id      = aws_subnet.demo_subnet.id
 route_table_id = aws_route_table.demo_rtb.id
}

resource "aws_security_group" "demo_sg" {
  name = "demo-sg"
  description = "Security group for web server"
  vpc_id = aws_vpc.demo_vpc.id
  #http
  ingress { 
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For demonstration purposes, restrict this in production
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # Allow all egress traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow egress to any destination
  }

  tags = {
    Name = "Demo SG"
  }
}

# EC2 instance
resource "aws_instance" "demo_ec2" {
  ami = "ami-0eb4694aa6f249c52"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.demo_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  user_data_base64 = "IyEvYmluL2Jhc2gKIyBVc2UgdGhpcyBmb3IgeW91ciB1c2VyIGRhdGEgKHNjcmlwdCBmcm9tIHRvcCB0byBib3R0b20pCiMgaW5zdGFsbCBodHRwZCAoTGludXggMiB2ZXJzaW9uKQp5dW0gdXBkYXRlIC15Cnl1bSBpbnN0YWxsIC15IGh0dHBkCnN5c3RlbWN0bCBzdGFydCBodHRwZApzeXN0ZW1jdGwgZW5hYmxlIGh0dHBkCmVjaG8gIjxoMT5IZWxsbyBXb3JsZCBmcm9tICQoaG9zdG5hbWUgLWYpPC9oMT4iID4gL3Zhci93d3cvaHRtbC9pbmRleC5odG1s"

  tags = {
    Name = "Demo EC2"
  }
}