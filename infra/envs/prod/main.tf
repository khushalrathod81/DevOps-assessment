terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

module "network" {
  source = "../../modules/network"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  common_tags        = var.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  environment            = var.environment
  aws_region             = var.aws_region
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_subnet_ids     = module.network.private_subnet_ids
  alb_security_group_id  = module.network.alb_security_group_id
  ecs_security_group_id  = module.network.ecs_security_group_id
  container_image        = var.container_image
  task_cpu               = var.task_cpu
  task_memory            = var.task_memory
  desired_count          = var.desired_count
  max_capacity           = var.max_capacity
  common_tags            = var.common_tags
}

module "rds" {
  source = "../../modules/rds"

  environment              = var.environment
  private_subnet_ids       = module.network.private_subnet_ids
  rds_security_group_id    = module.network.rds_security_group_id
  instance_class           = var.rds_instance_class
  allocated_storage        = var.rds_allocated_storage
  postgres_version         = var.postgres_version
  database_name            = var.database_name
  db_username              = var.db_username
  db_password              = var.db_password
  multi_az                 = var.rds_multi_az
  backup_retention_period  = var.backup_retention_period
  deletion_protection      = var.deletion_protection
  skip_final_snapshot      = var.skip_final_snapshot
  common_tags              = var.common_tags
}
