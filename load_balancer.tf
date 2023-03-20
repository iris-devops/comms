##################################################################################
# Load balanacer FasTrak Api
##################################################################################

resource "aws_lb" "reach-api-lb" {
  name               = local.lb_reach_api
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.subnet[*].id
  # security_groups    = [aws_security_group.ft-sg-lb.id, aws_security_group.ft-sg-web.id]
  tags = merge(local.common_tags, {Product = "reach-alb" })

  # enable_deletion_protection = true
}

resource "aws_lb_target_group" "reach-api-tg-ip" {
  name        = local.lb_tg_reach_api
  port        = var.http_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.reach-vpc.id

  # health_check {
  #   protocol = "TCP"
  #   # port     = var.http_port
  #   # path     = var.ft_api_healthCheckURL
  #   #matcher = "200-399"
  #   interval = 120
  #   #timeout = 10
  #   # healthy_threshold = 3
  #   # unhealthy_threshold = 3

  # }
  tags = merge(local.common_tags, {Product = "reach-alb" })
}

# 
# LB Listener forward
# 
resource "aws_lb_listener" "reach-api-lb-li-http" {
  load_balancer_arn = aws_lb.reach-api-lb.arn
  port              = var.http_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reach-api-tg-ip.arn
  }
  tags = merge(local.common_tags, {Product = "reach-alb" })
}

# resource "aws_api_gateway_vpc_link" "reach-api-lb-vpcl" {
#   name        = local.lb_vpcl_reach_api
#   description = local.lb_reach_api
#   target_arns = [aws_lb.reach-api-lb.arn]
# }


