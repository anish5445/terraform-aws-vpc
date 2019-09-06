resource "aws_security_group" "sgforendpoint" {
  name        = "EndpointSG"
  description = "Allow indbound and outbound traffic for VPC endpoint"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each            = toset(var.vpc_endpoints)
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = ["${aws_security_group.sgforendpoint.id}"]
  subnet_ids          = aws_subnet.private.*.id
  tags = merge(
    { Name = "${var.vpc_name}-${each.value}-endpoint" },
    var.tags
  )
}