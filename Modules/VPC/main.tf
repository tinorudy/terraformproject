#this config will be shared n used source= "../Modules/vpc into any environment..just edit variables in vars.tf and values in terraform.tfvars
#create VPC
resource "aws_vpc" "vpc" {
   cidr_block = "${var.vpc-cidr}"
   instance_tenancy = "default"
   enable_dns_support = true
   enable_dns_hostnames = true
   tags {
       Name = "dev"
   }
}

resource "aws_lb_target_group" "web-tg"  {
   name            = "web-target-group"
   port            = 80
   protocol        = "HTTP"
   vpc_id          = "${aws_vpc.vpc.id}"
}
#create a subnet: breaking down the network into subs;couldbe public facing subnet or private depends on use case
resource "aws_subnet" "subnet" {
   count             = "${length(var.sub-cidr)}" #length is whatever the list of sub-cidr is-this is going to be the dublin-private-cidr
   cidr_block        = "${element(var.sub-cidr,count.index)}" #element: loop through each values in sub-cidr 1 by 1; and count.index create each one
   vpc_id            = "${aws_vpc.vpc.id}"
   availability_zone = "${element(var.az,count.index)}"
   map_public_ip_on_launch = true
   tags{
      name = "dev_subnet"
   }
}
# Create an internet gateway for the VPC called gw and Associate gw to vpc
resource "aws_internet_gateway" "gw" {
   vpc_id = "${aws_vpc.vpc.id}"
   tags {
       name = "dev-InternetGateway"
   }
}
#Create a route table for the vpc
resource "aws_route_table" "route" {
   vpc_id = "${aws_vpc.vpc.id}"
   tags {
       Name = "dev-vpc_route_table"
   }
}
#create internet gateway to route all. to route traffic to the internet for web/app server
resource "aws_route" "main" {
  route_table_id         = "${aws_route_table.route.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

#Associate the public subnet to the internet_access route table created above
resource "aws_route_table_association" "route" {
  count = "${length(var.sub-cidr)}"
  subnet_id = "{element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.route.id}"
}
