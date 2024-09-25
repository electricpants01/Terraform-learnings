output "rds_endpoint" {
  description = "El endpoint del RDS de PostgreSQL"
  value       = aws_db_instance.todo_app_db.endpoint
}

# Output for db_name can be referenced from the variable
output "rds_db_name" {
  description = "El nombre de la base de datos"
  value       = var.db_name
}