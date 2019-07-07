provider "aws" {
  region = "${var.region}"
}

module "network" {
  source       = "../Modules/vpc"
  vpc-cidr     = "${var.dublin-vpc-cidr}"
  sub-cidr     = "${var.dublin-private-cidr}"
  #vpc_id       = "${module.my_vpc.vpc_id}"
  az           = "${var.dublin-azs}"
}

#module "my_ec2" {
#  source        = "../Modules/EC2"
#  ec2_count     = 2
#  ami_id        = "ami-08935252a36e25f85"
#  instance_type = "t2.micro"
#  subnet_id     = "${module.my_vpc.subnet_id}"
#}

#module "my_sg" {
#   source      = "../Modules/SECURITY"
#   vpc_id       = "${module.my_vpc.vpc_id}"
#}
