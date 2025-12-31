variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "service_name" {
  description = "Service name used for resource naming"
  type        = string
  default     = "social-media-repurposer"
}

variable "environment" {
  description = "Environment name (production/staging/dev)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "mycreatorkit.com"
}

# ==============================================================================
# APPLICATION SETTINGS
# ==============================================================================

variable "app_port" {
  description = "Port the Streamlit application runs on"
  type        = number
  default     = 8501
}

variable "app_count" {
  description = "Number of ECS tasks to run (budget: 1 task for cost optimization)"
  type        = number
  default     = 1

  validation {
    condition     = var.app_count >= 1
    error_message = "App count must be at least 1 to run the application."
  }
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = "/"
}

# ==============================================================================
# FARGATE SETTINGS (Budget-Optimized)
# ==============================================================================
# Using smallest valid Fargate configuration to minimize costs
# 256 CPU + 512 MB = ~$0.01235/hour = ~$9/month per task
# Valid combinations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html

variable "fargate_cpu" {
  description = "CPU units for Fargate task (256 = 0.25 vCPU, budget option)"
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.fargate_cpu)
    error_message = "Fargate CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "fargate_memory" {
  description = "Memory in MiB for Fargate task (512 MB, budget option)"
  type        = number
  default     = 512

  validation {
    condition = (
      # 256 CPU: 512, 1024, 2048
      (var.fargate_cpu == 256 && contains([512, 1024, 2048], var.fargate_memory)) ||
      # 512 CPU: 1024 to 4096 (in 1024 increments)
      (var.fargate_cpu == 512 && var.fargate_memory >= 1024 && var.fargate_memory <= 4096) ||
      # 1024 CPU: 2048 to 8192 (in 1024 increments)
      (var.fargate_cpu == 1024 && var.fargate_memory >= 2048 && var.fargate_memory <= 8192) ||
      # 2048 CPU: 4096 to 16384 (in 1024 increments)
      (var.fargate_cpu == 2048 && var.fargate_memory >= 4096 && var.fargate_memory <= 16384) ||
      # 4096 CPU: 8192 to 30720 (in 1024 increments)
      (var.fargate_cpu == 4096 && var.fargate_memory >= 8192 && var.fargate_memory <= 30720)
    )
    error_message = "Invalid CPU/Memory combination. See AWS Fargate task size documentation for valid pairs."
  }
}

# ==============================================================================
# NETWORKING (Public Subnets Only - No NAT Gateway Costs!)
# ==============================================================================
# Budget optimization: Using only public subnets to avoid NAT Gateway costs (~$32/month each)
# Tasks will get public IPs and communicate directly with the internet
# We use 2 subnets across 2 AZs because ALB requires at least 2 availability zones
# Even though we only run 1 task for budget reasons, the ALB needs multi-AZ setup

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets across 2 availability zones (required for ALB)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnets required for Application Load Balancer."
  }
}
