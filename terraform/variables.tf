# General variables
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string
  default     = "production"
}

variable "service_name" {
  description = "Service name used for resource naming"
  type        = string
  default     = "social-media-repurposer"
}

# Domain variables
variable "domain_name" {
  description = "Domain name for the application (managed in Cloudflare)"
  type        = string
  default     = "api.mycreatorkit.com"
}

# App Runner configuration
variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8000
}

variable "cpu" {
  description = "CPU units for App Runner (1024 = 1 vCPU, 2048 = 2 vCPU)"
  type        = number
  default     = 1024

  validation {
    condition     = contains([1024, 2048, 4096], var.cpu)
    error_message = "CPU must be 1024, 2048, or 4096"
  }
}

variable "memory" {
  description = "Memory in MB for App Runner (2048 = 2GB, 3072 = 3GB, 4096 = 4GB)"
  type        = number
  default     = 2048

  validation {
    condition     = contains([2048, 3072, 4096, 6144, 8192, 10240, 12288], var.memory)
    error_message = "Memory must be 2048, 3072, 4096, 6144, 8192, 10240, or 12288 MB"
  }
}

variable "max_concurrency" {
  description = "Maximum concurrent requests per instance"
  type        = number
  default     = 100
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 2
}
