# Región de AWS
variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

# VPC y Subnets
variable "vpc_cidr_block" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "CIDR block para la primera subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_2_cidr" {
  description = "CIDR block para la segunda subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_1" {
  description = "Zona de disponibilidad para la primera subnet"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Zona de disponibilidad para la segunda subnet"
  type        = string
  default     = "us-east-1b"
}

# Security group
variable "allowed_cidr_block" {
  description = "CIDR block permitido para acceder al RDS"
  type        = string
  default     = "0.0.0.0/0"  # Cambia esto para una IP más segura
}

# RDS Database
variable "db_allocated_storage" {
  description = "Tamaño del almacenamiento en GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Versión de PostgreSQL"
  type        = string
  default     = "16.4"
}

variable "db_instance_class" {
  description = "Tipo de instancia para RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "todo_app_db"
}

variable "db_username" {
  description = "Usuario administrador de la base de datos"
  type        = string
  default     = "locoto_user"
}

variable "db_password" {
  description = "Contraseña del administrador"
  type        = string
}

variable "publicly_accessible" {
  description = "Indica si la base de datos es accesible públicamente"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Días de retención de backups automáticos"
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Activar alta disponibilidad en varias AZ"
  type        = bool
  default     = false
}