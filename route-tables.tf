resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.name}_public_RT"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.name}_private_RT"
  }
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
resource "aws_route_table_association" "public" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = local.private_subnet_count
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}

