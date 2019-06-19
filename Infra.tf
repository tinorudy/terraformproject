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
  vpc_id                  = "${aws_vpc.main.id}"
  count                   = "${length(var.cdb)}"
  cidr_block              = "${element(var.cdb, count.index)}"
  availability_zone       = "${element(var.az, count.index)}"
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

#CREATE  INTERNET GATEWAY
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

#CREATE ROUTE TABLES
resource "aws_route_table" "my_route" {
  vpc_id = "${aws_vpc.main.id}"
  count  = "${length(var.cdb)}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Environment = "prod"
    Name        = "fikun"
  }
}

#CREATE ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "a" {
  count          = "${length(var.cdb)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.my_route.*.id, count.index)}"
}

#CREATE SECURITY GROUPS
resource "aws_security_group" "allowed-access" {
  name        = "sg"
  description = "Allowed inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["149.22.26.52/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#CREATE  EC2 INSTANCES
resource "aws_instance" "fife" {
  ami                         = "ami-08935252a36e25f85"
  instance_type               = "t2.micro"
  key_name                    = "tino"
  count                       = "${length(var.cdb)}"
  associate_public_ip_address = true
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.allowed-access.id}"]
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  tenancy                     = "default"

  tags {
    Name = "web-server"
  }
}

#CREATE APPLICATION LOAD BALANCER
resource "aws_lb" "tino_alb" {
  name               = "tino-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allowed-access.id}"]
  subnets            = ["${aws_subnet.public.*.id}"]

  enable_deletion_protection = false

  #access_logs {
  #bucket  = "${aws_s3_bucket.lb_logs.bucket}"
  #prefix  = "test-lb"
  #enabled = true
  #}

  tags = {
    Environment = "production"
  }
}

#CREATE LISTENER ON ALB

resource "aws_lb_listener" "tino-listens" {
  load_balancer_arn = "${aws_lb.tino_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#CREATE TARGET GROUP

resource "aws_lb_target_group" "tino-tg" {
  name     = "tino-alb-tino-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}

#resource "aws_vpc" "main" {
#cidr_block = "192.168.0.0/28"
#}

#CREATE TARGET GROUP ATTACHMENT

resource "aws_lb_target_group_attachment" "tino-tg-attach" {
  #count = "${var.ec2}"
  target_group_arn = "${aws_lb_target_group.tino-tg.arn}"
  target_id        = "${aws_instance.fife.0.id}"

  #target_id        = "${element(var.ec2, count.index)}"
  port = 80
}


#CREATE LAUNCH CONFIGURATION

data "aws_ami" "amzn-ami-hvm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2018.03.0.20181129-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_launch_configuration" "tino_launch" {
  name_prefix   = "launch_template"
  image_id      = "${data.aws_ami.amzn-ami-hvm.id}"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

#CREATE AUTO SCALING GROUP
resource "aws_autoscaling_group" "tino_asg" {
  name                 = "asg_template"
  launch_configuration = "${aws_launch_configuration.tino_launch.name}"
   vpc_zone_identifier       = ["${aws_subnet.public.*.id}"]
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
}
