output "subnets" {
  value = "${aws_subnet.subnet.*.id}"
}

output "security_group_ids" {
  value = "${aws_security_group.sg.id}"
}

output "vpc-id" {
  value = "${aws_vpc.vpc.id}"
}

output "target-group-arn" {
  value = "${aws_lb_target_group.web-tg.arn}"
}
