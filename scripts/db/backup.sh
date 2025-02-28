#!/bin/bash
# Dify Database Backup Script
# This script creates a backup of the PostgreSQL database used by Dify

# Load environment variables
source "$(dirname "$0")/../../.env"

# Set default values if not provided in .env
DB_USER=${POSTGRES_USER:-postgres}
DB_PASSWORD=${POSTGRES_PASSWORD:-postgres-password}
DB_NAME=${POSTGRES_DB:-dify}
DB_HOST=${POSTGRES_HOST:-postgres}
DB_PORT=${POSTGRES_PORT:-5432}

# Create backup directory if it doesn't exist
BACKUP_DIR="$(dirname "$0")/../../backups/db"
mkdir -p "$BACKUP_DIR"

# Generate timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/dify_db_backup_$TIMESTAMP.sql.gz"

echo "Starting Dify database backup..."
echo "Database: $DB_NAME on $DB_HOST:$DB_PORT"

# Execute the backup
if [ "$ENVIRONMENT" = "prod" ]; then
    # In production, connect to the database container
    docker exec -t $(docker ps -qf "name=dify-workflow_postgres") \
        pg_dump -U "$DB_USER" -d "$DB_NAME" | gzip > "$BACKUP_FILE"
else
    # In development, use local connection
    PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" | gzip > "$BACKUP_FILE"
fi

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: $BACKUP_FILE"
    echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
    
    # Cleanup old backups (keep last 7 days)
    find "$BACKUP_DIR" -name "dify_db_backup_*.sql.gz" -type f -mtime +7 -delete
    echo "Cleaned up backups older than 7 days"
else
    echo "Backup failed!"
    exit 1
fi

# Create a metadata file with information about the backup
echo "Database: $DB_NAME" > "$BACKUP_FILE.meta"
echo "Timestamp: $(date)" >> "$BACKUP_FILE.meta"
echo "Environment: $ENVIRONMENT" >> "$BACKUP_FILE.meta"
echo "Dify Version: $(docker exec -t $(docker ps -qf "name=dify-workflow_api") cat /app/api/version.txt 2>/dev/null || echo 'unknown')" >> "$BACKUP_FILE.meta"

echo "Backup process completed"
