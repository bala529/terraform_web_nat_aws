# terraform script

provider "aws" {
  access_key = "<<access_key>>"
  secret_key = "<<secret_key>>"
  region     = "eu-west-1"
}


# create VPC

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


# create "Public" subnet inside vpc

resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/20"

  tags {
    Name = "public"
  }
}


# create Private subnet inside VPC

resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.16.0/20"

  tags {
    Name = "private"
  }
}

# create internet gateway for public VPC

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "internet"
  }
}

# route table for "Public subnet 10.0.0.0/20"

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = "${aws_internet_gateway.gw.id}"
 }

 tags {
   Name = "public"
 }
}

# route table association

resource "aws_route_table_association" "pub" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# Elastic ip for natgateway

resource "aws_eip" "nat" {
  vpc      = true
}

# Creates NAT gateway

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"
}

# routing table for "private subnet 10.0.16.0/20"

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = "${aws_nat_gateway.natgw.id}"
 }

 tags {
   Name = "private"
 }
}

# associating private routing table to "private subnet 10.0.16.0/20"

resource "aws_route_table_association" "pri" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}

# EC2 instance for web server

## security group for instance

resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.main.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "web" {

  instance_type = "t2.micro"

  # AMI generated from packer
  ami = "<<PACKER_AMI>>"

  # The name of our SSH keypair we created above.
  key_name = "<<YOUR KEY PAIR NAME>>"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]


  subnet_id = "${aws_subnet.private.id}"

  tags {
    Name = "Nginx"
  }
  }
