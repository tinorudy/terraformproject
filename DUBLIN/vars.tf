#variable "access_key" {}
#variable "secret_key" {}

variable "region" {}
variable "dublin-vpc-cidr" {}
variable "dublin-private-cidr" {
   type = "list"
}

variable "dublin-azs" {
   type = "list"
}
