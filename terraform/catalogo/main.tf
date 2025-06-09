terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  shared_config_files = ["~/.aws/credentials"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "default"
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for EC2 Instances
resource "aws_iam_role_policy" "ec2_instance_policy" {
  name = "ec2-instance-policy"
  role = aws_iam_role.ec2_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

# VPC y Subnets
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "cotizador-catalogo"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = var.environment
  }
}

# Security Groups
resource "aws_security_group" "catalogo" {
  name        = "catalogo-sg"
  description = "Security group for catalogo services"
  vpc_id      = module.vpc.vpc_id

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
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.catalogo.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  key_name      = var.key_name

  user_data = <<EOF
    #!/bin/bash
    echo "[default]" > /home/ec2-user/.aws/credentials
    echo "aws_access_key_id=${var.aws_access_key_id}" >> /home/ec2-user/.aws/credentials
    echo "aws_secret_access_key=${var.aws_secret_access_key}" >> /home/ec2-user/.aws/credentials
    echo "aws_session_token=${var.aws_session_token}" >> /home/ec2-user/.aws/credentials
    
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
  subnet_id     = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.catalogo.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  key_name      = var.key_name

  user_data = <<EOF
    #!/bin/bash
    echo "[default]" > /home/ec2-user/.aws/credentials
    echo "aws_access_key_id=${var.aws_access_key_id}" >> /home/ec2-user/.aws/credentials
    echo "aws_secret_access_key=${var.aws_secret_access_key}" >> /home/ec2-user/.aws/credentials
    echo "aws_session_token=${var.aws_session_token}" >> /home/ec2-user/.aws/credentials
    
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

resource "aws_instance" "catalogo_filtros" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.catalogo.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  key_name      = var.key_name

  user_data = <<EOF
    #!/bin/bash
    echo "[default]" > /home/ec2-user/.aws/credentials
    echo "aws_access_key_id=${var.aws_access_key_id}" >> /home/ec2-user/.aws/credentials
    echo "aws_secret_access_key=${var.aws_secret_access_key}" >> /home/ec2-user/.aws/credentials
    echo "aws_session_token=${var.aws_session_token}" >> /home/ec2-user/.aws/credentials
    
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
    Name = "catalogo-filtros"
    Environment = var.environment
  }
}

# Eliminamos la tercera instancia ya que solo tenemos 2 zonas de disponibilidad
# resource "aws_instance" "catalogo_filtros" {
#   ami           = var.ami_id
#   instance_type = "t2.micro"
#   subnet_id     = module.vpc.public_subnets[2]
#   vpc_security_group_ids = [aws_security_group.catalogo.id]
#   iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
#   key_name      = var.key_name
# 
#   user_data = <<EOF
#     #!/bin/bash
#     echo "[default]" > /home/ec2-user/.aws/credentials
#     echo "aws_access_key_id=${var.aws_access_key_id}" >> /home/ec2-user/.aws/credentials
#     echo "aws_secret_access_key=${var.aws_secret_access_key}" >> /home/ec2-user/.aws/credentials
#     echo "aws_session_token=${var.aws_session_token}" >> /home/ec2-user/.aws/credentials
#     
#     # Instalar Docker
#     yum update -y
#     yum install -y docker
#     service docker start
#     usermod -a -G docker ec2-user
#     
#     # Instalar Docker Compose
#     curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#     chmod +x /usr/local/bin/docker-compose
#     
#     # Clonar el repositorio
#     git clone https://github.com/tu-repositorio.git /opt/cotizador
#     cd /opt/cotizador
#     
#     # Iniciar servicios
#     docker-compose up -d
# EOF
# 
#   tags = {
#     Name = "catalogo-filtros"
#     Environment = var.environment
#   }
# }


