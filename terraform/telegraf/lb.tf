resource "aws_lb" "lb" {
  name               = "telegraf-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = data.aws_subnet_ids.public_subnets.ids

  enable_deletion_protection = false
}

resource "aws_security_group" "lb_sg" {
  name        = "telegraf-lb-sg"
  description = "Allow telegraf traffic into load balancer"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.webhook_port
    to_port     = var.webhook_port
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
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "telegraf-lb-tg"
  port        = var.relay_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  health_check {
    path                = "/ping"
    port                = var.relay_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 60
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "lb_target_group2" {
  name        = "telegraf-lb-tg2"
  port        = var.webhook_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  health_check {
    path                = "/ping"
    port                = var.webhook_port
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 300
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

resource "aws_lb_listener" "front_end2" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.webhook_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group2.arn
  }
}

resource "aws_route53_record" "telegraf" {
  zone_id = data.aws_route53_zone.relops_mozops_net.zone_id
  name    = "telegraf.relops.mozops.net"
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
