aws_region             = "us-east-1"
environment            = "prod"
vpc_cidr              = "10.0.0.0/16"
public_subnets_cidr   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr  = ["10.0.10.0/24", "10.0.11.0/24"]

container_image       = "nginx:latest"
task_cpu              = "256"
task_memory           = "512"
desired_count         = 3
max_capacity          = 6

rds_instance_class    = "db.t3.small"
rds_allocated_storage = 100
postgres_version      = "14"
database_name         = "devops_assessment"
db_username           = "postgres"

rds_multi_az          = true
backup_retention_period = 30
deletion_protection   = true

common_tags = {
  Environment = "prod"
  Project     = "devops-assessment"
  ManagedBy   = "terraform"
}
