resource "aws_db_instance" "db" {
  identifier                   = var.db_instance_identifier
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = var.max_allocated_storage
  db_name                      = var.db_name
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  manage_master_user_password = var.manage_master_user_password
  username                    = var.master_username
  parameter_group_name         = var.parameter_group_name
  skip_final_snapshot          = var.skip_final_snapshot
  multi_az                     = var.multi_az
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = var.publicly_accessible
  storage_type                 = var.storage_type
  backup_retention_period      = var.backup_retention_period
  storage_encrypted            = true
  allow_major_version_upgrade  = true
  apply_immediately            = true
  deletion_protection          = true # Enable termination protection
  db_subnet_group_name            = var.db_subnet_group
  vpc_security_group_ids          = var.vpc_security_group_ids
  copy_tags_to_snapshot           = true
  depends_on                      = [aws_db_subnet_group.db_subnet_group]
  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]
  tags = {
    TerraformManaged = true
  }
}

# resource "aws_db_instance" "db_read_replica" {
#   count                        = var.read_replica_count
#   identifier                   = "${var.db_instance_identifier}-db-read"
#   allocated_storage            = var.allocated_storage
#   max_allocated_storage        = var.max_allocated_storage
#   engine                       = var.engine
#   engine_version               = var.engine_version
#   instance_class               = var.instance_class
#   username                     = var.username
#   password                     = var.password
#   parameter_group_name         = var.parameter_group_name
#   skip_final_snapshot          = var.skip_final_snapshot
#   multi_az                     = var.multi_az
#   performance_insights_enabled = var.performance_insights_enabled
#   publicly_accessible          = var.publicly_accessible
#   storage_type                 = var.storage_type
#   backup_retention_period      = var.backup_retention_period
#   storage_encrypted            = true

#   db_subnet_group_name   = var.db_subnet_group
#   vpc_security_group_ids = var.vpc_security_group_ids
#   copy_tags_to_snapshot  = true
#   depends_on             = [aws_db_subnet_group.db_subnet_group]

#   source_db_instance_identifier = aws_db_instance.db.id

# }

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = var.db_parameter_group_name
  family = var.db_parameter_group_family
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids
  tags       = var.db_subnet_group_tags
}