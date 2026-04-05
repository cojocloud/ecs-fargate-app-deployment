variable "env_suffix" {
  description = "Environment suffix used in resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ECS task security group"
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID of the ALB"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
