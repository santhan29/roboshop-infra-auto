module "ingress_alb" {
  source = "terraform-aws-modules/alb/aws" 

  internal = false 
  name    = "${var.project_name}-${var.environment}-ingress-alb"   
  vpc_id  = local.vpc_id 
  subnets = local.public_subnet_id 
  security_groups = [data.aws_ssm_parameter.ingress_alb_sg_id.value] 
  create_security_group = false 
  enable_deletion_protection = false 

  tags = merge(
    var.common_tags,
    var.ingress_alb_tags

  ) 
}

resource "aws_lb_listener" "http" { 
  load_balancer_arn = module.ingress_alb.arn 
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type    = "text/html"
      message_body  = "<h1> hello, i am from web ALB<h1>"
      status_code = "200" 
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [
    {
      name    = "roboshop-${var.environment}"  #expense-dev 
      type    = "A" 
      alias   = {
        name = module.ingress_alb.dns_name 
        zone_id = module.ingress_alb.zone_id 
      } 
      allow_overwrite = true 
    } 
  ]

}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.ingress_alb.arn 
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.https_certificate_arn 

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type    = "text/html"
      message_body  = "<h1> hello, i am from web ALB HTTPS<h1>"
      status_code = "200" 
    }
  }
  
}

resource "aws_lb_target_group" "roboshop" {
  name     = local.resource_name      #"expense-dev-backend1" 
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id  
  target_type = "ip" 

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2 
    interval = 5 
    matcher = "200-299"
    path = "/" 
    protocol = "HTTP"
    port = 8080 
    timeout = 4 
  }
} 

resource "aws_lb_listener_rule" "roboshop" { 
  listener_arn = aws_lb_listener.https.arn  
  priority     = 100  #low priority will be evaluated first 

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.roboshop.arn  
  }

  condition {
    host_header {  
      values = ["roboshop-${var.environment}.${var.zone_name}"] 
    }
  }
} 