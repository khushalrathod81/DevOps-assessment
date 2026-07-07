terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-db-subnet-group"
    }
  )
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.environment}-postgres"
  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.db_username
  password = var.db_password

  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  publicly_accessible   = false
  skip_final_snapshot   = var.skip_final_snapshot
  deletion_protection   = var.deletion_protection
  backup_retention_period = var.backup_retention_period
  backup_window         = "03:00-04:00"
  maintenance_window    = "mon:04:00-mon:05:00"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]

  multi_az = var.multi_az

  enabled_cloudwatch_logs_exports = ["postgresql"]

  parameter_group_name = aws_db_parameter_group.main.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-postgres"
    }
  )
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  name   = "${var.environment}-postgres-params"
  family = "postgres${var.postgres_version}"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-postgres-params"
    }
  )
}
