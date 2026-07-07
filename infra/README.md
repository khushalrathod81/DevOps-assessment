# Terraform Infrastructure

This directory contains Terraform code for AWS infrastructure with ALB → ECS/Fargate → RDS architecture.

## Directory Structure

```
infra/
├── modules/
│   ├── network/          # VPC, subnets, security groups
│   ├── ecs/              # ECS cluster, task definition, service
│   └── rds/              # RDS PostgreSQL database
├── envs/
│   ├── dev/              # Development environment
│   └── prod/             # Production environment
└── README.md
```

## Environments

### Development (dev)
- **Instance Type**: t3.micro
- **Backup Retention**: 7 days
- **Deletion Protection**: Disabled
- **Use Case**: Development and testing

### Production (prod)
- **Instance Type**: t3.small
- **Backup Retention**: 30 days
- **Deletion Protection**: Enabled
- **Use Case**: Production workloads

## Setup

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured with credentials
- AWS Account

### Deploy Development Environment

```bash
cd envs/dev
terraform init
terraform plan -refresh=false
terraform apply
```

### Deploy Production Environment

```bash
cd envs/prod
terraform init
terraform plan -refresh=false
terraform apply
```

## Architecture

```
Internet (0.0.0.0/0)
    ↓
Application Load Balancer (ALB)
    ↓
ECS Fargate Container Service
    ↓
RDS PostgreSQL (Private)
```

## Network Design

### VPC
- CIDR: 10.0.0.0/16

### Public Subnets
- Subnet 1: 10.0.1.0/24 (Availability Zone A)
- Subnet 2: 10.0.2.0/24 (Availability Zone B)
- Route to Internet Gateway

### Private Subnets
- Subnet 1: 10.0.10.0/24 (Availability Zone A)
- Subnet 2: 10.0.11.0/24 (Availability Zone B)
- Route through NAT Gateway

## Security Groups

### ALB Security Group
- **Inbound**: 80 (HTTP), 443 (HTTPS) from 0.0.0.0/0
- **Outbound**: All traffic

### ECS Security Group
- **Inbound**: 8080 from ALB security group
- **Outbound**: All traffic

### RDS Security Group
- **Inbound**: 5432 (PostgreSQL) from ECS security group only
- **Outbound**: None required

## ECS Configuration

### Cluster
- Name: `devops-assessment-cluster`
- Capacity Provider: FARGATE

### Task Definition
- **CPU**: 256 units
- **Memory**: 512 MB
- **Container**: Nginx (placeholder)
- **Port**: 8080

### Service
- **Desired Count**: 2 tasks
- **Launch Type**: FARGATE
- **Load Balancer**: ALB
- **Target Group**: Port 8080

## RDS Configuration

### Database
- **Engine**: PostgreSQL
- **Version**: 14.x
- **Instance Class**: t3.micro (dev) / t3.small (prod)
- **Allocated Storage**: 20 GB
- **Multi-AZ**: Enabled
- **Backup Retention**: 7 days (dev) / 30 days (prod)
- **Deletion Protection**: Disabled (dev) / Enabled (prod)

### Security
- **Private Subnet**: Yes
- **Public Accessibility**: No
- **Encryption**: Enabled

## Validation

```bash
# Check formatting
terraform fmt -check -recursive

# Initialize
terraform init

# Validate syntax
terraform validate

# Generate plan
terraform plan -refresh=false
```

## Outputs

- `alb_dns_name`: DNS name of the Application Load Balancer
- `rds_endpoint`: RDS instance endpoint
- `rds_port`: RDS instance port
- `ecs_cluster_name`: ECS cluster name
- `ecs_service_name`: ECS service name

## Notes

- The Terraform code uses modules for better organization and reusability
- Each environment has its own state file and tfvars
- AWS deployment is optional; the plan can be reviewed without applying
- The application container uses Nginx as a placeholder

## Cost Optimization

- Development uses smaller instance types (t3.micro)
- Production uses slightly larger instances (t3.small)
- Backup retention varies by environment
- Adjust instance types and counts based on actual requirements
