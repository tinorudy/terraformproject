#create aws security group
resource "aws_security_group" "sg" {
  name = "sg"
  description = "ec2 security group rules"
  vpc_id = "${aws_vpc.vpc.id}"

  #ssh access
  ingress {
    from_port = 22
    to_port   = 22
    protocol = "tcp"
    cidr_blocks = ["192.168.0.0/23"]
}
#http access from anywhere
ingress {
  from_port = 80
  to_port   = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
#https access
ingress {
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
#ingress {
#   from_port = 22
#   to_port  = 22
#   protocol = "tcp"
#   cidr_blocks = ["MY IP"]
#}


egress {
  from_port = 0
  to_port  = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}
