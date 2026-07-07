#!/bin/bash

# Database backup script
# Creates a timestamped backup of the PostgreSQL database

set -e

# Configuration
DB_HOST="localhost"
DB_PORT="5432"
DB_USER="postgres"
DB_NAME="devops_assessment"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

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

# Create backup
echo "[INFO] Creating backup: ${BACKUP_FILE}"
if docker compose exec -T postgres pg_dump -U "${DB_USER}" "${DB_NAME}" > "${BACKUP_FILE}"; then
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    echo "[SUCCESS] Backup created successfully"
    echo "[INFO] Backup file: ${BACKUP_FILE}"
    echo "[INFO] Backup size: ${BACKUP_SIZE}"
    
    # Verify backup file
    if [ -s "${BACKUP_FILE}" ]; then
        echo "[INFO] Backup file verified (size: $(wc -l < ${BACKUP_FILE}) lines)"
    else
        echo "[WARNING] Backup file appears to be empty"
        exit 1
    fi
else
    echo "[ERROR] Failed to create backup"
    rm -f "${BACKUP_FILE}"
    exit 1
fi
