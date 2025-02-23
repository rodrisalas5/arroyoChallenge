# Vamos a setear nuestras credenciales en archivo de configuración de AWS, evitando hardcodear información sensible

# variable "AWS_ACCESS_KEY" {}
# variable "AWS_SECRET_KEY" {}

// Región AWS
variable "aws_region" {
  default = "us-east-1"
}

// CIDR
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

// Definimos subneteado público y privado
variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 1,
    private = 2    # Requisito RDS
  }
}

// Configuración RDS y EC2
variable "settings" {
  description = "Configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage   = 10
      engine              = "mysql"
      engine_version      = "8.0.27"
      instance_class      = "db.t2.micro"
      db_name             = "Arroyo-PoC"
      skip_final_snapshot = true
    },
    "web_app" = {
      count         = 1
      instance_type = "t2.micro"
    }
  }
}

// CIDR blocks para subneteado público
variable "public_subnet_cidr_blocks" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

// CIDR blocks para subneteado privado
variable "private_subnet_cidr_blocks" {
  description = "Available CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}

// IP que accede mediante SSH a instancia
variable "my_ip" {
  description = "Your IP address"
  type        = string
  sensitive   = true
}

// DB User
variable "db_username" {
  description = "Database master user"
  type        = string
  sensitive   = true
}

// DB Password
variable "db_password" {
  description = "Database master user password"
  type        = string
  sensitive   = true
}