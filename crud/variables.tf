variable "db_username" {
  type    = string
  default = "todo_user"
}

variable "db_password" {
  type = string
  default = "locoto123"
}

variable "db_name" {
  type    = string
  default = "todo_db"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}