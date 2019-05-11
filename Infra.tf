provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

#CREATE VPC DEFINITIONS
resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/23"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "fife"
  }
}
#CREATE SUBNETS
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.main.id}"
  count             = "${length(var.cdb)}"
  cidr_block        = "${element(var.cdb, count.index)}"
  availability_zone = "${element(var.az, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "LOLA"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.pri_cdb}"
  availability_zone = "${var.pri_az}"

  tags = {
    Name = "FIKUN"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "my_route" {
   vpc_id = "${aws_vpc.main.id}"
   count = "${length(var.cdb)}"

   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.gw.id}"
   }
   tags = {
      Environment = "prod"
      Name        = "fikun"
   }
}

resource "aws_route_table_association" "a" {
   count = "${length(var.cdb)}"
   subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
   route_table_id = "${element(aws_route_table.my_route.*.id, count.index)}"
}

resource "aws_security_group" "allowed-access" {
   name        = "sg"
   description = "Allowed inbound traffic"
   vpc_id      = "${aws_vpc.main.id}"

   ingress {
      from_port = 80
      to_port   = 80
      protocol  = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
      from_port = 22
      to_port   = 22
      protocol  = "TCP"
      cidr_blocks = ["86.177.47.36/32"]
   }

   egress {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_instance" "fife" {
   ami = "ami-08935252a36e25f85"
   instance_type = "t2.micro"
   key_name = "tino"
   count = "${length(var.cdb)}"
   associate_public_ip_address = true
   monitoring = true
   vpc_security_group_ids = ["${aws_security_group.allowed-access.id}"]
   subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
   tenancy = "default"
   tags {
      Name = "web-server"
   }
}