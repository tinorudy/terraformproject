resource " aws_lb" "alb" {
  name                  = "{var.alb_name}"
  internal              = "false"
  load_balancer_type    = "application"
  security_groups       = ["${var.security_groups}"]
  subnets               = ["${var.subnet_ids}"]
  tags {
    Name = "{var.alb_name}"
  }
}
resource "aws_lb_listener" "alb" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  protocol          = "HTTP"
  port              = "80"
  default_action {
    type    = "forward"
    target_group_arn = "${var.target_group_arn}"
  }
}
