# Dify Workflow Makefile
# This Makefile provides shortcuts for common operations

# Default environment is development
ENV ?= dev

# Load environment variables if .env exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: help setup start stop restart logs backup restore clean verify structure

help: ## Show this help
	@echo "Dify Workflow Management"
	@echo ""
	@echo "Usage: make [target] [ENV=dev|prod]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Setup the environment (copy .env.template to .env if not exists)
	@if [ ! -f .env ]; then \
		echo "Creating .env file from template..."; \
		cp .env.template .env; \
		echo "Please edit .env file with your configuration"; \
	else \
		echo ".env file already exists"; \
	fi
	@mkdir -p logs/nginx backups/db storage
	@echo "Creating required directories..."
	@echo "Setup complete. Edit .env file with your configuration before starting."

start: ## Start Dify services
	@echo "Starting Dify services in $(ENV) environment..."
	ENVIRONMENT=$(ENV) docker-compose up -d
	@echo "Services started. Web UI available at http://localhost:3000"

stop: ## Stop Dify services
	@echo "Stopping Dify services..."
	docker-compose down
	@echo "Services stopped"

restart: stop start ## Restart Dify services

logs: ## Show logs from all services
	@echo "Showing logs from all services (Ctrl+C to exit)..."
	docker-compose logs -f

backup: ## Backup the database
	@echo "Backing up the database..."
	./scripts/db/backup.sh
	@echo "Backup complete"

restore: ## Restore the database from a backup file
	@if [ -z "$(file)" ]; then \
		echo "Error: No backup file specified"; \
		echo "Usage: make restore file=path/to/backup.sql.gz"; \
		exit 1; \
	fi
	@echo "Restoring database from $(file)..."
	./scripts/db/restore.sh $(file)
	@echo "Restore complete"

clean: ## Remove all containers, volumes, and data (DESTRUCTIVE!)
	@echo "WARNING: This will remove all containers, volumes, and data!"
	@read -p "Are you sure you want to continue? (y/n): " confirm; \
	if [ "$$confirm" = "y" ]; then \
		echo "Stopping and removing all containers..."; \
		docker-compose down -v; \
		echo "Removing data directories..."; \
		rm -rf storage/* backups/* logs/*; \
		echo "Clean complete"; \
	else \
		echo "Operation cancelled"; \
	fi

# AWS deployment helpers
aws-configure: ## Configure AWS deployment settings
	@echo "Configuring AWS deployment settings..."
	@mkdir -p infrastructure/aws
	@echo "Please edit infrastructure/aws/terraform.tfvars with your AWS configuration"

aws-deploy: ## Deploy to AWS (requires Terraform)
	@echo "Deploying to AWS..."
	@if [ ! -d "infrastructure/aws/terraform" ]; then \
		echo "Error: AWS Terraform configuration not found"; \
		echo "Please run 'make aws-configure' first"; \
		exit 1; \
	fi
	@cd infrastructure/aws/terraform && terraform init && terraform apply
	@echo "Deployment complete"

verify: ## Verify Docker Compose configuration and environment variables
	@./scripts/verify-config.sh

structure: ## Generate directory structure visualization
	@./scripts/generate-structure.sh
