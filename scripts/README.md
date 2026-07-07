# Database Scripts

This directory contains utility scripts for database backup and restore operations.

## Scripts

### backup.sh
Creates a timestamped backup of the PostgreSQL database.

**Usage:**
```bash
./scripts/backup.sh
```

**Output:**
- Backup file in `./backups/devops_assessment_YYYY-MM-DD_HHMMSS.sql`
- File size information
- Verification that backup file is not empty

**Requirements:**
- Docker Compose running (database container must be up)
- PostgreSQL tools installed in container
- Write permission to `./backups` directory

### restore.sh
Restores a PostgreSQL database from a backup file.

**Usage:**
```bash
./scripts/restore.sh <backup_file>
```

**Example:**
```bash
./scripts/restore.sh ./backups/devops_assessment_2024-01-01_120000.sql
```

**Features:**
- Verifies backup file exists
- Checks database container is running
- Prompts for confirmation before restoring
- Drops existing database
- Creates new database
- Restores from backup
- Verifies restore with table schema and record count

**Requirements:**
- Docker Compose running (database container must be up)
- PostgreSQL tools installed in container
- Backup file must exist

## Workflow

### Create a Backup

```bash
cd scripts
./backup.sh
# Output: ./backups/devops_assessment_2024-01-01_120000.sql
```

### Restore from Backup

```bash
cd scripts
./restore.sh ../backups/devops_assessment_2024-01-01_120000.sql
```

### Verify Restore

The restore script automatically verifies:
1. Table schema is intact
2. Record counts match backup

## Making Scripts Executable

```bash
chmod +x scripts/backup.sh
chmod +x scripts/restore.sh
```

## Common Issues

### Container Not Running
```
[ERROR] PostgreSQL container is not running
```

**Solution:**
```bash
cd db
docker compose up -d
```

### Backup File Not Found
```
[ERROR] Backup file not found
```

**Solution:**
- Check backup file path
- List backups: `ls -la backups/`
- Use absolute path if needed

### Restore Confirmation
```
[PROMPT] Continue? (yes/no):
```

**Response:** Type `yes` to confirm restore

## Backup Location

All backups are stored in the `./backups` directory at the repository root.

```bash
ls -lh backups/
```

## Manual Backup/Restore

If scripts don't work, use Docker Compose directly:

**Backup:**
```bash
docker compose exec postgres pg_dump -U postgres devops_assessment > backup.sql
```

**Restore:**
```bash
docker compose exec postgres psql -U postgres -d devops_assessment < backup.sql
```
