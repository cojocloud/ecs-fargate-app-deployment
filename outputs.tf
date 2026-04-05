##############################################
# Outputs
##############################################

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "service_name" {
  description = "ECS Service name"
  value       = module.ecs.service_name
}

output "task_role_arn" {
  description = "Task Execution Role ARN"
  value       = module.iam.task_execution_role_arn
}

output "subdomain_url" {
  description = "Application URL via subdomain"
  value       = "https://${var.domain_name}"
}
