terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC existente
data "aws_vpc" "existing" {
  id = "vpc-0440f3de1664612d6"
}

# Subredes existentes
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["public-*", "public"]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

# Tabla de enrutamiento existente
data "aws_route_table" "existing" {
  filter {
    name   = "association.main"
    values = ["true"]
  }
  vpc_id = data.aws_vpc.existing.id
}

# Security Groups
resource "aws_security_group" "catalogo" {
  name        = "catalogo-sg"
  description = "Security group for catalogo services"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8083
    to_port     = 8083
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
    Name = "sg-catalogo"
  }
}

# EC2 Instances
resource "aws_instance" "catalogo_productos" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = element(tolist(data.aws_subnets.public.ids), 0)
  vpc_security_group_ids = [aws_security_group.catalogo.id]
  key_name      = var.key_name

  user_data = <<EOF
    #!/bin/bash
    # Instalar Docker
    yum update -y
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user
    
    # Instalar Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Clonar el repositorio
    git clone https://github.com/tu-repositorio.git /opt/cotizador
    cd /opt/cotizador
    
    # Iniciar servicios
    docker-compose up -d
EOF

  tags = {
    Name = "catalogo-productos"
    Environment = var.environment
  }
}

resource "aws_instance" "catalogo_materiales" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = element(tolist(data.aws_subnets.public.ids), 1)
  vpc_security_group_ids = [aws_security_group.catalogo.id]
  key_name      = var.key_name

  user_data = <<EOF
    #!/bin/bash
    # Instalar Docker
    yum update -y
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user
    
    # Instalar Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Clonar el repositorio
    git clone https://github.com/tu-repositorio.git /opt/cotizador
    cd /opt/cotizador
    
    # Iniciar servicios
    docker-compose up -d
EOF

  tags = {
    Name = "catalogo-materiales"
    Environment = var.environment
  }
}
#   tags = {
#     Name = "catalogo-filtros"
#     Environment = var.environment
#   }
# }


