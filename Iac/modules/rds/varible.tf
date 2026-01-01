variable "db_instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "allocated_storage" {
  type        = number
  default     = 0
  description = "allocates dtorage for rds instance"
}

variable "max_allocated_storage" {
  type        = number
  default     = 0
  description = "allocates dtorage for rds instance"
}

variable "db_name" {
  type        = string
  default     = ""
  description = "describe db name details"
}

variable "engine" {
  type        = string
  default     = ""
  description = "describe engine name for database"
}

variable "engine_version" {
  type        = number
  default     = 0
  description = "describe db engine version"
}

variable "instance_class" {
  type        = string
  default     = ""
  description = "describe db instance class"
}
variable "parameter_group_name" {
  type        = string
  default     = ""
  description = "set db parameter group name for database"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "set multiaz setup for db instance"
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "set performance_insights for db instance"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "set publicly_accessible for db instance"
}

variable "storage_type" {
  type        = string
  default     = ""
  description = "set storage type for db instance"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "set sg for db instance"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "set final snapshot details"
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}

variable "db_subnet_ids" {
  description = "A list of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_subnet_group_tags" {
  description = "A map of tags to assign to the DB subnet group"
  type        = map(string)
}

variable "db_subnet_group" {
  type        = string
  default     = ""
  description = "db_subnet_group for db instance"
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group"
  type        = string
}

variable "db_parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
}

variable "db_parameter_group" {
  type        = string
  default     = ""
  description = "db_parameter_group for db instance"
}

variable "backup_retention_period" {
  type        = number
  default     = 0
  description = "backup retentation period for db instance"
}

variable "db_credentials" {
  type        = string
  default     = ""
  description = "db_credentials for dev database"
}

variable "manage_master_user_password" {
  type = bool
}
variable "master_username" {
  type = string
  description = "master username for rds instance"
}

# variable "read_replica_count" {
#   type        = string
#   default     = ""
#   description = "read_replica_count value for rds"
# }