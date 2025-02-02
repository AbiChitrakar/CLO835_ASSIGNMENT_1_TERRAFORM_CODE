provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB Security Group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
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

  tags = {
    Name = "alb-sg"
  }
}

# Second: Create ALB
resource "aws_lb" "app_lb" {
  name               = "webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
  depends_on = [aws_security_group.alb_sg]

  tags = {
    Name = "webapp-alb"
  }
}

# Third: Create Target Groups
resource "aws_lb_target_group" "blue" {
  name     = "blue-tg"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/blue/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 30
    timeout             = 5
  }
  depends_on = [aws_lb.app_lb]
}

resource "aws_lb_target_group" "pink" {
  name     = "pink-tg"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/pink/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 30
    timeout             = 5
  }

  depends_on = [aws_lb.app_lb]
}

resource "aws_lb_target_group" "lime" {
  name     = "lime-tg"
  port     = 8083
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/lime/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 30
    timeout             = 5
  }

  depends_on = [aws_lb.app_lb]
}

# Fourth: Create Listener and Rules
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Please use /blue, /pink, or /lime path"
      status_code  = "200"
    }
  }

  depends_on = [aws_lb.app_lb]
}

resource "aws_lb_listener_rule" "blue" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  condition {
    path_pattern {
      values = ["/blue/*"]
    }
  }

  depends_on = [aws_lb_listener.front_end]
}

resource "aws_lb_listener_rule" "pink" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pink.arn
  }

  condition {
    path_pattern {
      values = ["/pink/*"]
    }
  }

  depends_on = [aws_lb_listener.front_end]
}

resource "aws_lb_listener_rule" "lime" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lime.arn
  }

  condition {
    path_pattern {
      values = ["/lime/*"]
    }
  }

  depends_on = [aws_lb_listener.front_end]
}
