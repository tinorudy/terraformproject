variable "secret_key" {}
variable "access_key" {}
variable "region" {}

variable "az" {
  type = "list"
}

variable "cdb" {
  type = "list"
}

variable "pri_az" {
   type = "string"
}
variable "pri_cdb" {
   type = "string"
}
