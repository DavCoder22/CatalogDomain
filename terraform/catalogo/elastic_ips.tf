# Elastic IPs para las instancias EC2
resource "aws_eip" "catalogo_productos" {
  domain = "vpc"
  
  tags = {
    Name        = "eip-catalogo-productos"
    Environment = var.environment
    Service     = "productos"
  }
}

resource "aws_eip" "catalogo_materiales" {
  domain = "vpc"
  
  tags = {
    Name        = "eip-catalogo-materiales"
    Environment = var.environment
    Service     = "materiales"
  }
}

# Asociar EIPs a las instancias
resource "aws_eip_association" "catalogo_productos" {
  instance_id   = aws_instance.catalogo_productos.id
  allocation_id = aws_eip.catalogo_productos.id
  
  depends_on = [aws_instance.catalogo_productos]
}

resource "aws_eip_association" "catalogo_materiales" {
  instance_id   = aws_instance.catalogo_materiales.id
  allocation_id = aws_eip.catalogo_materiales.id
  
  depends_on = [aws_instance.catalogo_materiales]
}

# Outputs para las IPs estáticas
output "productos_public_ip" {
  description = "Public IP address of productos instance"
  value       = aws_eip.catalogo_productos.public_ip
}

output "materiales_public_ip" {
  description = "Public IP address of materiales instance"
  value       = aws_eip.catalogo_materiales.public_ip
}

output "productos_private_ip" {
  description = "Private IP address of productos instance"
  value       = aws_instance.catalogo_productos.private_ip
}

output "materiales_private_ip" {
  description = "Private IP address of materiales instance"
  value       = aws_instance.catalogo_materiales.private_ip
} 