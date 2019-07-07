#create an elastic IP, for the Nat-gateway.needs to have a public IP to be internet facing
resource "aws_eip" "nat-eip" {
  count = "${length(var.sub-cidr)}"
  vpc = true
  depends_on = ["aws_internet_gateway.gw"]
}
#create Nat-gateway on the public subnet which is represented as the Web
resource "aws_nat_gateway" "nat" {
  count        = "${length(var.sub-cidr)}"
  allocation_id = "${element(aws_eip.nat-eip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"
  depends_on = ["aws_internet_gateway.gw"]
}
