# ==============================================================================
# Application Load Balancer with Cloudflare DNS
# ==============================================================================
#
# DNS SETUP:
# - Domain registered with Cloudflare Registrar
# - Using Cloudflare for DNS management (manual)
# - ACM certificate validation done via Cloudflare DNS
# - Route53 not used for this deployment
#
# CERTIFICATE:
# - SSL certificate must be validated manually in Cloudflare
# - Add CNAME validation records from AWS Console to Cloudflare DNS
# - See outputs for detailed setup instructions
#
# ==============================================================================

resource "aws_lb" "main" {
  name                       = "${var.service_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = aws_subnet.public[*].id
  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      name = "${var.service_name}-alb"
    }
  )
}

resource "aws_lb_target_group" "app" {
  name                 = "${var.service_name}-tg"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = merge(
    local.common_tags,
    {
      name = "${var.service_name}-tg"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ==============================================================================
# HTTPS Listener (Port 443)
# ==============================================================================
# Certificate must be validated manually via Cloudflare DNS before HTTPS works

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
