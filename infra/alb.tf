resource "aws_lb" "example_alb" {
  name               = "${local.sig}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example_alb_sg.id]
  subnets            = tolist(aws_subnet.example_subnet[*].id)
}

resource "aws_lb_listener" "example_alb_listener" {
  load_balancer_arn = aws_lb.example_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_alb_tg.arn
  }

  tags = (merge(local.default_tags,
    {
      "Name" = "${local.sig}-alb-listener",
    }
  ))
}

resource "aws_lb_target_group" "example_alb_tg" {
  name        = "${local.sig}-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.example_vpc.id
  target_type = "lambda"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/api/v1/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = (merge(local.default_tags,
    {
      "Name" = "${local.sig}-alb-tg",
    }
  ))
}

resource "aws_lb_target_group_attachment" "example_alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.example_alb_tg.arn
  target_id        = aws_lambda_function.example_api.arn
}

resource "aws_security_group" "example_alb_sg" {
  name        = "${local.sig}-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = (merge(local.default_tags,
    {
      "Name" = "${local.sig}-alb-sg",
    }
  ))
}
