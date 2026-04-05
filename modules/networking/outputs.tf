output "app_task_sg_id" {
  description = "Security group ID for ECS tasks"
  value       = aws_security_group.app_task_sg.id
}
