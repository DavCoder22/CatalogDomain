output "catalogo_productos_ip" {
  value = aws_eip.catalogo_productos.public_ip
  description = "Elastic IP of productos service"
}

output "catalogo_materiales_ip" {
  value = aws_eip.catalogo_materiales.public_ip
  description = "Elastic IP of materiales service"
}

output "security_group_id" {
  value = aws_security_group.catalogo.id
  description = "ID of the security group"
}
