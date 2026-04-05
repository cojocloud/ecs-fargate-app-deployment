##############################################
# ECS Fargate Service with ALB + ECR + Secrets
##############################################

module "ecr" {
  source = "./modules/ecr"

  env_suffix  = local.env_suffix
  region      = var.region
  image_tag   = var.image_tag
  common_tags = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  env_suffix     = local.env_suffix
  app_secret_arn = var.app_secret_arn
  common_tags    = local.common_tags
}

module "networking" {
  source = "./modules/networking"

  env_suffix  = local.env_suffix
  vpc_id      = var.vpc_id
  alb_sg_id   = var.alb_sg_id
  common_tags = local.common_tags
}

module "acm" {
  source = "./modules/acm"

  domain_name    = var.domain_name
  hosted_zone_id = data.aws_route53_zone.main.zone_id
  common_tags    = local.common_tags
}

module "alb" {
  source = "./modules/alb"

  env_suffix      = local.env_suffix
  alb_sg_id       = var.alb_sg_id
  public_subnets  = var.public_subnets
  vpc_id          = var.vpc_id
  certificate_arn = module.acm.certificate_arn
  common_tags     = local.common_tags
}

# Route53 alias record wiring ALB → subdomain
# Kept in root to avoid circular dependency between acm and alb modules
resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

module "ecs" {
  source = "./modules/ecs"

  env_suffix              = local.env_suffix
  region                  = var.region
  app_cpu                 = var.app_cpu
  app_memory              = var.app_memory
  image_tag               = var.image_tag
  ecr_repository_url      = module.ecr.repository_url
  app_secret_arn          = var.app_secret_arn
  task_execution_role_arn = module.iam.task_execution_role_arn
  public_subnets          = var.public_subnets
  app_task_sg_id          = module.networking.app_task_sg_id
  app_sg_id               = var.app_sg_id
  target_group_arn        = module.alb.target_group_arn
  desired_count           = var.desired_count
  common_tags             = local.common_tags

  # Ensure image is pushed and ALB listener exists before service creation
  depends_on = [module.ecr, module.alb]
}
