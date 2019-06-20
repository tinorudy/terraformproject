resource "aws_security_group" "allowed-access" {
  name        = "sg"
  description = "allow inbound traffic"
  #vpc_id      = "${module.my_vpc.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["149.22.13.168/32"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/23"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "aws_security_group_id" {
  value = "${aws_security_group.allowed-access.id}"
}
