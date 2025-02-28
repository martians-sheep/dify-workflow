# Dify AWS Infrastructure Variables
# This file defines all variables used in the Terraform configuration

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "dify-workflow"
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "The availability zones to deploy resources"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

# Database variables
variable "db_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "The allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "dify"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "dify"
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

# Redis variables
variable "redis_node_type" {
  description = "The node type for the ElastiCache Redis cluster"
  type        = string
  default     = "cache.t3.small"
}

# ECS variables
variable "ecs_task_cpu" {
  description = "The CPU units for the ECS task"
  type        = number
  default     = 1024
}

variable "ecs_task_memory" {
  description = "The memory for the ECS task in MiB"
  type        = number
  default     = 2048
}

variable "api_image" {
  description = "The Docker image for the Dify API service"
  type        = string
  default     = "langgenius/dify-api:latest"
}

variable "web_image" {
  description = "The Docker image for the Dify Web service"
  type        = string
  default     = "langgenius/dify-web:latest"
}

# Domain variables
variable "domain_name" {
  description = "The domain name for the Dify application"
  type        = string
  default     = ""
}

variable "create_route53_records" {
  description = "Whether to create Route53 records"
  type        = bool
  default     = false
}

# Backup variables
variable "backup_retention_days" {
  description = "The number of days to retain backups"
  type        = number
  default     = 7
}
