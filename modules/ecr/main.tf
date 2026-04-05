resource "aws_ecr_repository" "app_repo" {
  name                 = "webapp-${var.env_suffix}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.common_tags, {
    Name = "ecr-webapp-${var.env_suffix}"
  })
}

resource "null_resource" "frontend_image" {
  provisioner "local-exec" {
    command = "bash -lc 'aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app_repo.repository_url} && docker build -t frontend ./frontend && docker tag frontend:latest ${aws_ecr_repository.app_repo.repository_url}:${var.image_tag} && docker push ${aws_ecr_repository.app_repo.repository_url}:${var.image_tag}'"
  }

  depends_on = [aws_ecr_repository.app_repo]
}
