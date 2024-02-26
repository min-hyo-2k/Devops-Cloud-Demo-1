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
  #ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  user_data = <<EOF
    #! /bin/bash
    sudo su
    sudo yum update
    sudo yum install -y httpd
    sudo chkconfig httpd on
    sudo service httpd start
    echo "<h1>Deployed EC2 With Terraform</h1>" | sudo tee /var/www/html/index.html
    EOF
  tags = {
    Name = "Demo EC2"
  }
}