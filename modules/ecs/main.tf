resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/webapp-${var.env_suffix}"
  retention_in_days = 7
  tags              = var.common_tags
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "ecs-cluster-${var.env_suffix}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.common_tags
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "webapp-task-${var.env_suffix}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_cpu
  memory                   = var.app_memory
  execution_role_arn       = var.task_execution_role_arn

  depends_on = [aws_cloudwatch_log_group.ecs_log_group]

  container_definitions = jsonencode([
    {
      name      = "webapp"
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "ENV"
          value = var.env_suffix
        }
      ]

      secrets = [
        {
          name      = "APP_SECRET"
          valueFrom = var.app_secret_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name             = "webapp-service-${var.env_suffix}"
  cluster          = aws_ecs_cluster.app_cluster.id
  task_definition  = aws_ecs_task_definition.app_task.arn
  desired_count    = var.desired_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [var.app_task_sg_id, var.app_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "webapp"
    container_port   = 80
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  tags = var.common_tags
}
