resource "aws_vpc" "main" {
   cidr_block = "${var.vpc_cidr}"
   instance_tenancy = "${var.tenancy}"

   tags {
      Name = "main"
   }
}

resource "aws_subnet" "main" {
   vpc_id = "${var.vpc_id}"
   cidr_block = "${var.subnet_cidr}"
   #map_public_ip_on_launch = true

   tags {
   Name = "public"
   }
}

#resource "aws_subnet" "main1" {
   #vpc_id = "${var.vpc_id}"
   #cidr_block = "${var.subnet_cidr1}"

   #tags {
   #Name = "private"
   #}
#}

resource "aws_internet_gateway" "igw" {
   vpc_id = "${var.vpc_id}"

tags {
   Name = "${var.name}"
   }
}

resource "aws_route_table" "my_route" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"

}

  resource "aws_route_table_association" "a" {
    subnet_id      = "${aws_subnet.main.id}"
    vpc_main_route_table_id = "${aws_route_table.my_route.id}"
}
}





output "vpc_id"{
   value = "${aws_vpc.main.id}"
}

output "subnet_id"{
   value = "${aws_subnet.main.id}"
}

output "gateway_id" {
   value = "${aws_internet_gateway.igw.id}"
}

output "vpc_main_route_table_id"{
   value = "${aws_route_table.my_route.id}"
}
