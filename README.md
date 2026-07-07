# DevOps Assessment: Terraform + Database Reliability

This repository contains a complete DevOps infrastructure assessment demonstrating Terraform infrastructure design, database management, and GitHub Actions CI/CD.

## Project Structure

```
.
├── infra/                          # Terraform infrastructure code
│   ├── modules/
│   │   ├── network/               # VPC, subnets, security groups
│   │   ├── ecs/                   # ECS cluster, task definition, service
│   │   └── rds/                   # RDS PostgreSQL database
│   ├── envs/
│   │   ├── dev/                   # Development environment
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars
│   │   │   ├── backend.tf
│   │   │   └── outputs.tf
│   │   └── prod/                  # Production environment
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── terraform.tfvars
│   │       ├── backend.tf
│   │       └── outputs.tf
│   └── README.md                  # Terraform documentation
├── db/
│   ├── docker-compose.yml         # Local PostgreSQL setup
│   ├── migrations/
│   │   ├── 001_create_tables.sql
│   │   └── 002_create_indexes.sql
│   └── seeds/
│       └── seed_data.sql
├── scripts/
│   ├── backup.sh                  # Database backup script
│   └── restore.sh                 # Database restore script
├── .github/
│   └── workflows/
│       └── terraform.yml          # GitHub Actions workflow
└── README.md                      # Main documentation
```

## Quick Start

### Local Database Setup

```bash
# Start local PostgreSQL database
cd db
docker compose up -d

# Wait for database to be ready (10-15 seconds)
sleep 15

# Run migrations and seed data
docker compose exec postgres psql -U postgres -d devops_assessment < migrations/001_create_tables.sql
docker compose exec postgres psql -U postgres -d devops_assessment < migrations/002_create_indexes.sql
docker compose exec postgres psql -U postgres -d devops_assessment < seeds/seed_data.sql
```

### Database Backup and Restore

```bash
# Create a backup
./scripts/backup.sh

# Restore from backup
./scripts/restore.sh backups/devops_assessment_YYYY-MM-DD_HHMMSS.sql
```

### Terraform Validation

```bash
cd infra/envs/dev
terraform fmt -check
terraform init
terraform validate
terraform plan -refresh=false
```

## Features

### Part 1: AWS Infrastructure Design
- Internet → ALB → ECS/Fargate → RDS architecture
- VPC with public and private subnets
- Security groups for ALB, ECS, and RDS
- ECS cluster with Fargate task definition
- Private RDS PostgreSQL instance

### Part 2: Environment Handling
- Separate dev and prod environments
- Environment-specific variables and tfvars
- Dev: t3.micro, 7-day backup retention, deletion protection disabled
- Prod: t3.small, 30-day backup retention, deletion protection enabled

### Part 3: GitHub Actions CI/CD
- Automatic Terraform formatting check
- Terraform validation and initialization
- Terraform plan with PR comments

### Part 4: Local Database
- Docker Compose PostgreSQL setup
- `hotel_bookings` table with booking data
- `booking_events` table with event tracking

### Part 5: Query Optimization
- Composite index on (city, created_at) for optimized queries
- 100+ seed bookings with multiple cities and organizations
- Query optimization explained in TERRAFORM.md

### Part 6: Backup and Restore
- Timestamped backup script using pg_dump
- Restore script with validation
- Verification steps in documentation

## Setup Instructions

### Prerequisites
- Docker and Docker Compose
- Terraform >= 1.0
- AWS CLI (for Terraform)
- PostgreSQL client tools (psql)
- Bash shell

### Step 1: Clone the Repository

```bash
git clone https://github.com/khushalrathod81/devops-assessment.git
cd devops-assessment
```

### Step 2: Start Local Database

```bash
cd db
docker compose up -d
sleep 15

# Initialize database
docker compose exec postgres psql -U postgres -d devops_assessment < migrations/001_create_tables.sql
docker compose exec postgres psql -U postgres -d devops_assessment < migrations/002_create_indexes.sql
docker compose exec postgres psql -U postgres -d devops_assessment < seeds/seed_data.sql
```

### Step 3: Verify Database

```bash
# Connect to database
docker compose exec postgres psql -U postgres -d devops_assessment

# Sample queries
SELECT COUNT(*) FROM hotel_bookings;
SELECT COUNT(*) FROM booking_events;
```

### Step 4: Test Backup and Restore

```bash
cd ../scripts
./backup.sh
./restore.sh ../backups/devops_assessment_YYYY-MM-DD_HHMMSS.sql
```

### Step 5: Validate Terraform

```bash
cd ../infra/envs/dev
terraform fmt -check
terraform init
terraform validate
terraform plan -refresh=false
```

## Verification

### Database Verification

```bash
# Check tables exist
docker compose exec postgres psql -U postgres -d devops_assessment -c "\dt"

# Check record counts
docker compose exec postgres psql -U postgres -d devops_assessment -c "
SELECT 'hotel_bookings' as table_name, COUNT(*) as record_count FROM hotel_bookings
UNION ALL
SELECT 'booking_events', COUNT(*) FROM booking_events;
"

# Verify restore
./scripts/restore.sh ../backups/devops_assessment_YYYY-MM-DD_HHMMSS.sql
docker compose exec postgres psql -U postgres -d devops_assessment -c "SELECT COUNT(*) FROM hotel_bookings;"
```

### Terraform Verification

```bash
cd infra/envs/dev
terraform validate  # Should show "Success!"
terraform plan -refresh=false  # Should show planned changes
```

## Key Implementation Details

### Database Indexing Strategy

For the query:
```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

A composite index on `(city, created_at)` is created for optimal query performance. See `infra/terraform.md` for detailed explanation.

### Terraform Environments

- **dev**: Small instance (t3.micro), 7-day backup retention
- **prod**: Larger instance (t3.small), 30-day backup retention, deletion protection

Each environment has its own state file, variables, and configuration.

### GitHub Actions Workflow

The workflow runs on PRs and:
1. Checks Terraform formatting
2. Initializes Terraform
3. Validates configuration
4. Generates and comments with plan

## Troubleshooting

### Database Connection Issues

```bash
# Check if container is running
docker compose ps

# View logs
docker compose logs postgres

# Restart services
docker compose restart
```

### Terraform Issues

```bash
# Clear local state and reinitialize
rm -rf .terraform .terraform.lock.hcl
terraform init

# Validate syntax
terraform fmt -recursive
terraform validate
```

### Backup/Restore Issues

```bash
# Verify permissions
ls -la scripts/
chmod +x scripts/backup.sh scripts/restore.sh

# Check backup directory
ls -la backups/
```

## Architecture

### AWS Infrastructure (Terraform)

```
Internet
   ↓
  ALB (Application Load Balancer)
   ↓
ECS/Fargate (Application Servers)
   ↓
  RDS (Private PostgreSQL Database)
```

### Security

- ALB: Open to internet (0.0.0.0/0)
- ECS: Only accessible from ALB
- RDS: Only accessible from ECS

## Files Overview

See individual README files in each directory for detailed documentation:
- `infra/README.md` - Terraform infrastructure details
- `db/README.md` - Database schema and queries
- `scripts/README.md` - Backup/restore procedures

## License

MIT
