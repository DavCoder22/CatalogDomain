

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c2b8ca1dad447f8a"  # Amazon Linux 2 AMI (HVM), SSD Volume Type
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "pc1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "docker_images" {
  description = "Map of Docker images for each microservice"
  type        = map(string)
  default     = {
    productos = ""
    materiales = ""
    filtros = ""
  }
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "git_repository_url" {
  description = "URL del repositorio Git"
  type        = string
  default     = "https://github.com/tu-repositorio.git"
}
