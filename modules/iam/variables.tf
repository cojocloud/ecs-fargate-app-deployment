variable "env_suffix" {
  description = "Environment suffix used in resource names"
  type        = string
}

variable "app_secret_arn" {
  description = "ARN of the Secrets Manager secret"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
