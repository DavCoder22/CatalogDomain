output "vpc_id" {
  value = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
  description = "List of private subnet IDs"
}

output "catalogo_productos_ip" {
  value = aws_instance.catalogo_productos.public_ip
  description = "Public IP of productos service"
}

output "catalogo_materiales_ip" {
  value = aws_instance.catalogo_materiales.public_ip
  description = "Public IP of materiales service"
}

output "catalogo_filtros_ip" {
  value = aws_instance.catalogo_filtros.public_ip
  description = "Public IP of filtros service"
}

output "security_group_id" {
  value = aws_security_group.catalogo.id
  description = "ID of the security group"
}
