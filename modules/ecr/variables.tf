variable "env_suffix" {
  description = "Environment suffix used in resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to push"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
