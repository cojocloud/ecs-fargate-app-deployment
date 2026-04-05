variable "env_suffix" {
  description = "Environment suffix used in resource names"
  type        = string
}

variable "region" {
  description = "AWS region for CloudWatch logs"
  type        = string
}

variable "app_cpu" {
  description = "CPU units for the ECS task"
  type        = number
}

variable "app_memory" {
  description = "Memory in MB for the ECS task"
  type        = number
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL for the container image"
  type        = string
}

variable "app_secret_arn" {
  description = "ARN of the Secrets Manager secret"
  type        = string
  sensitive   = true
}

variable "task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  type        = string
}

variable "public_subnets" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "app_task_sg_id" {
  description = "Security group ID for ECS tasks (managed by networking module)"
  type        = string
}

variable "app_sg_id" {
  description = "Additional security group ID for ECS tasks"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
