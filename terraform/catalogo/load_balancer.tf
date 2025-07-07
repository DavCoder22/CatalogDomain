# Application Load Balancer
resource "aws_lb" "catalogo" {
  name               = "catalogo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public.ids

  enable_deletion_protection = false

  tags = {
    Name        = "catalogo-alb"
    Environment = var.environment
  }
}

# Security Group para el ALB
resource "aws_security_group" "alb" {
  name        = "catalogo-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "sg-catalogo-alb"
  }
}

# Target Group para Productos
resource "aws_lb_target_group" "productos" {
  name     = "catalogo-productos-tg"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "catalogo-productos-tg"
    Environment = var.environment
  }
}

# Target Group para Materiales
resource "aws_lb_target_group" "materiales" {
  name     = "catalogo-materiales-tg"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "catalogo-materiales-tg"
    Environment = var.environment
  }
}

# Target Group para Filtros
resource "aws_lb_target_group" "filtros" {
  name     = "catalogo-filtros-tg"
  port     = 8083
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "catalogo-filtros-tg"
    Environment = var.environment
  }
}

# Target Group Attachment para Productos
resource "aws_lb_target_group_attachment" "productos" {
  target_group_arn = aws_lb_target_group.productos.arn
  target_id        = aws_instance.catalogo_productos.id
  port             = 8081
}

# Target Group Attachment para Materiales
resource "aws_lb_target_group_attachment" "materiales" {
  target_group_arn = aws_lb_target_group.materiales.arn
  target_id        = aws_instance.catalogo_materiales.id
  port             = 8082
}

# Listener para Productos (puerto 80)
resource "aws_lb_listener" "productos" {
  load_balancer_arn = aws_lb.catalogo.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.productos.arn
  }
}

# Listener Rule para Materiales (puerto 8082)
resource "aws_lb_listener_rule" "materiales" {
  listener_arn = aws_lb_listener.productos.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.materiales.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/materiales*"]
    }
  }
}

# Listener Rule para Filtros (puerto 8083)
resource "aws_lb_listener_rule" "filtros" {
  listener_arn = aws_lb_listener.productos.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.filtros.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/buscar*"]
    }
  }
}

# Listener Rule para Swagger Productos
resource "aws_lb_listener_rule" "swagger_productos" {
  listener_arn = aws_lb_listener.productos.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.productos.arn
  }

  condition {
    path_pattern {
      values = ["/swagger*"]
    }
  }
}

# Listener Rule para Swagger Materiales
resource "aws_lb_listener_rule" "swagger_materiales" {
  listener_arn = aws_lb_listener.productos.arn
  priority     = 400

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.materiales.arn
  }

  condition {
    path_pattern {
      values = ["/swagger*"]
    }
  }
}

# Outputs
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.catalogo.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.catalogo.zone_id
}

output "productos_url" {
  description = "URL for productos service"
  value       = "http://${aws_lb.catalogo.dns_name}/api/v1/productos"
}

output "materiales_url" {
  description = "URL for materiales service"
  value       = "http://${aws_lb.catalogo.dns_name}/api/v1/materiales"
}

output "filtros_url" {
  description = "URL for filtros service"
  value       = "http://${aws_lb.catalogo.dns_name}/api/v1/buscar"
}

output "swagger_productos_url" {
  description = "Swagger URL for productos service"
  value       = "http://${aws_lb.catalogo.dns_name}/swagger/index.html"
}

output "swagger_materiales_url" {
  description = "Swagger URL for materiales service"
  value       = "http://${aws_lb.catalogo.dns_name}/swagger/index.html"
} 