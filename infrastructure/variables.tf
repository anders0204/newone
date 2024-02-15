variable "resource_group_name" {
  default = "newone-rg"
}

variable "location" {
  default = "norwayeast"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
