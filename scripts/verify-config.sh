#!/bin/bash
# Verify Docker Compose configuration and environment variables

# Change to the project root directory
cd "$(dirname "$0")/.."

# Check if .env file exists
if [ ! -f .env ]; then
  echo "Error: .env file not found. Please run 'make setup' first."
  exit 1
fi

# Verify Docker Compose configuration
echo "Verifying Docker Compose configuration..."
if docker-compose config > /dev/null; then
  echo "✅ Docker Compose configuration is valid."
else
  echo "❌ Docker Compose configuration is invalid."
  exit 1
fi

# Check required environment variables
echo "Checking required environment variables..."
required_vars=(
  "POSTGRES_USER"
  "POSTGRES_PASSWORD"
  "POSTGRES_DB"
  "DIFY_SECRET_KEY"
  "OPENAI_API_KEY"
)

missing_vars=0
for var in "${required_vars[@]}"; do
  if ! grep -q "^${var}=" .env || grep -q "^${var}=$" .env; then
    echo "❌ Missing or empty environment variable: ${var}"
    missing_vars=$((missing_vars + 1))
  fi
done

if [ $missing_vars -eq 0 ]; then
  echo "✅ All required environment variables are set."
else
  echo "❌ ${missing_vars} required environment variables are missing or empty."
  echo "Please update your .env file with the required values."
  exit 1
fi

# Check if Docker is running
echo "Checking if Docker is running..."
if docker info > /dev/null 2>&1; then
  echo "✅ Docker is running."
else
  echo "❌ Docker is not running. Please start Docker and try again."
  exit 1
fi

echo "All checks passed! Your configuration is valid."
