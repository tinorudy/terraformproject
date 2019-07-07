variable "alb_name" {}
variable "subnet_ids" {
   type = "list"
}
variable "security_groups" {
   type = "list"}
variable "target_group_arn" {}
