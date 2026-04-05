resource "aws_security_group" "app_task_sg" {
  name        = "webapp-task-sg-${var.env_suffix}"
  description = "SG for ECS tasks: allows all egress; ALB allowed to connect on port 80"
  vpc_id      = var.vpc_id
  tags        = var.common_tags

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound for ECR, Secrets Manager, AWS endpoints"
  }
}

resource "aws_security_group_rule" "allow_alb_to_tasks" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_task_sg.id
  source_security_group_id = var.alb_sg_id
  description              = "Allow ALB to reach tasks on port 80"
}

resource "aws_security_group_rule" "alb_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.alb_sg_id
  description       = "Allow HTTPS from internet to ALB"
}
