#!/bin/bash

# Database restore script
# Restores a PostgreSQL database from a backup file

set -e

# Configuration
DB_HOST="localhost"
DB_PORT="5432"
DB_USER="postgres"
DB_NAME="devops_assessment"
DB_PASSWORD="postgres"

# Check if backup file is provided
if [ -z "$1" ]; then
    echo "[ERROR] Usage: ./restore.sh <backup_file>"
    echo "[INFO] Example: ./restore.sh ./backups/devops_assessment_2024-01-01_120000.sql"
    exit 1
fi

BACKUP_FILE="$1"

# Verify backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    echo "[ERROR] Backup file not found: ${BACKUP_FILE}"
    exit 1
fi

# Check file size
BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
echo "[INFO] Backup file: ${BACKUP_FILE}"
echo "[INFO] Backup size: ${BACKUP_SIZE}"
echo "[INFO] Backup contains $(wc -l < ${BACKUP_FILE}) lines"

# Check if database container is running
echo "[INFO] Checking if PostgreSQL container is running..."
if ! docker compose ps postgres | grep -q "Up"; then
    echo "[ERROR] PostgreSQL container is not running. Please start it with: docker compose up -d"
    exit 1
fi

# Wait for database to be ready
echo "[INFO] Waiting for database to be ready..."
for i in {1..30}; do
    if docker compose exec -T postgres pg_isready -U "${DB_USER}" &> /dev/null; then
        echo "[INFO] Database is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "[ERROR] Database is not ready after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Confirm before restoring
echo ""
echo "[WARNING] This will restore the database from backup: ${BACKUP_FILE}"
echo "[WARNING] Existing data in '${DB_NAME}' will be overwritten."
read -p "[PROMPT] Continue? (yes/no): " -r CONFIRM

if [[ ! $CONFIRM =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "[INFO] Restore cancelled"
    exit 0
fi

# Drop existing database
echo "[INFO] Dropping existing database..."
docker compose exec -T postgres psql -U "${DB_USER}" -c "DROP DATABASE IF EXISTS ${DB_NAME};" || true

# Create new database
echo "[INFO] Creating new database..."
docker compose exec -T postgres psql -U "${DB_USER}" -c "CREATE DATABASE ${DB_NAME};"

# Restore from backup
echo "[INFO] Restoring database from backup..."
if docker compose exec -T postgres psql -U "${DB_USER}" -d "${DB_NAME}" < "${BACKUP_FILE}"; then
    echo "[SUCCESS] Database restored successfully"
else
    echo "[ERROR] Failed to restore database"
    exit 1
fi

# Verify restore
echo "[INFO] Verifying restore..."
echo "[INFO] Checking table schema..."
docker compose exec -T postgres psql -U "${DB_USER}" -d "${DB_NAME}" -c "\dt"

echo "[INFO] Checking record counts..."
docker compose exec -T postgres psql -U "${DB_USER}" -d "${DB_NAME}" <<EOF
SELECT 
    'hotel_bookings' as table_name, 
    COUNT(*) as record_count 
FROM hotel_bookings
UNION ALL
SELECT 
    'booking_events', 
    COUNT(*) 
FROM booking_events;
EOF

echo ""
echo "[SUCCESS] Restore verification complete"
echo "[INFO] Database is ready for use"
