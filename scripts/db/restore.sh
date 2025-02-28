#!/bin/bash
# Dify Database Restore Script
# This script restores a PostgreSQL database backup for Dify

# Load environment variables
source "$(dirname "$0")/../../.env"

# Set default values if not provided in .env
DB_USER=${POSTGRES_USER:-postgres}
DB_PASSWORD=${POSTGRES_PASSWORD:-postgres-password}
DB_NAME=${POSTGRES_DB:-dify}
DB_HOST=${POSTGRES_HOST:-postgres}
DB_PORT=${POSTGRES_PORT:-5432}

# Check if backup file is provided
if [ -z "$1" ]; then
    echo "Error: No backup file specified"
    echo "Usage: $0 <backup_file.sql.gz>"
    
    # List available backups
    BACKUP_DIR="$(dirname "$0")/../../backups/db"
    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        echo "Available backups:"
        ls -lt "$BACKUP_DIR" | grep ".sql.gz$" | awk '{print $9}' | head -10
    fi
    
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file does not exist: $BACKUP_FILE"
    exit 1
fi

# Confirm restore operation
echo "WARNING: This will overwrite the current database ($DB_NAME) with the backup."
echo "Backup file: $BACKUP_FILE"
read -p "Are you sure you want to continue? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore operation cancelled."
    exit 0
fi

echo "Starting database restore..."

# Stop the Dify services to prevent data corruption
echo "Stopping Dify services..."
if [ "$ENVIRONMENT" = "prod" ]; then
    docker-compose -f "$(dirname "$0")/../../docker-compose.yml" stop api web
else
    docker-compose -f "$(dirname "$0")/../../docker-compose.yml" stop api web
fi

# Execute the restore
echo "Restoring database from backup..."
if [ "$ENVIRONMENT" = "prod" ]; then
    # In production, connect to the database container
    gunzip -c "$BACKUP_FILE" | docker exec -i $(docker ps -qf "name=dify-workflow_postgres") \
        psql -U "$DB_USER" -d "$DB_NAME"
else
    # In development, use local connection
    gunzip -c "$BACKUP_FILE" | PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME"
fi

# Check if restore was successful
if [ $? -eq 0 ]; then
    echo "Restore completed successfully"
else
    echo "Restore failed!"
    echo "Starting Dify services again..."
    docker-compose -f "$(dirname "$0")/../../docker-compose.yml" start api web
    exit 1
fi

# Start the Dify services again
echo "Starting Dify services..."
docker-compose -f "$(dirname "$0")/../../docker-compose.yml" start api web

echo "Restore process completed"
echo "Metadata for the restored backup:"
if [ -f "$BACKUP_FILE.meta" ]; then
    cat "$BACKUP_FILE.meta"
else
    echo "No metadata file found for this backup"
fi
