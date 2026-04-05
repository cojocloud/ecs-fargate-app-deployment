# terraform-ecs-ecr-alb

## Terraform Project 4: End-To-End Terraform Automation for Container Application Deployment with Automated ECR Image Delivery + Secrets-backed ECS Fargate Tasks + ALB Routing and CloudWatch Observability

**Architectural Diagram:**

<img width="750" height="572" alt="AWS ECS TF-Copy of Page-1 drawio" src="https://github.com/user-attachments/assets/e94e673b-5517-463d-a036-1777ea348e9f" />

## Real-world Problem

**Problem summary:**

You need to run a containerized web application in production without managing EC2 hosts, with secure secrets, automated image delivery, and public access behind a load balancer.

**Challenges:** building and storing container images, providing tasks secure access to secrets, ensuring tasks can pull images and report logs, exposing the app reliably to users, and deploying repeatably across environments.

## Solution Summary

**How this project solves it:**

1. **ECR repository:** Stores and versions container images so deployments use tagged images.

2. **Local image push (or CI integration):** Ensures the image is available in ECR before registering the task.

3. **ECS Fargate task + service:** Runs containers serverlessly (no host management) with specified CPU/memory and platform version.

4. **ALB + target group + listener:** Routes HTTP traffic to tasks, and health checks ensure only healthy tasks receive traffic.

5. **IAM execution role + Secrets Manager mapping:** Lets tasks securely retrieve secrets (no plaintext creds in code).

6. **CloudWatch logs:** Centralizes application logs for troubleshooting.

7. **Security groups + network config:** Ensures tasks have outbound access to AWS APIs/ECR and restricts inbound to the ALB.

8. **Terraform (IaC):** Makes this architecture reproducible, reviewable, and version-controllable across dev/stage/prod.

## Step-By-Step Implementation

**Install Terraform:** [https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

**Install AWS CLI:** [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

**Configure AWS CLI:** [https://youtu.be/TF9oisb1QJQ](https://youtu.be/TF9oisb1QJQ)

**Create an S3 Bucket** _(optional — only required if you want Terraform state stored in S3)_:

```bash
aws s3api create-bucket --bucket tf-state-<your-suffix> --region us-east-1
```

**Create DynamoDB table for state locking** _(optional — only required if you want Terraform state locking)_:

```bash
aws dynamodb create-table \
  --table-name tf-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
  --region us-east-1
```

**Install git:** [https://git-scm.com/downloads](https://git-scm.com/downloads)

**Clone the repo:**

```bash
git clone https://github.com/bhavukm/terraform-ecs-ecr-alb.git
cd terraform-ecs-ecr-alb
```

## Filling in dev.tfvars

Before running Terraform, populate `dev.tfvars` with values specific to your AWS account:

**Networking**

- `vpc_id` — ID of your VPC (e.g. `vpc-0abc1234...`). Find it in the AWS Console under VPC Dashboard.
- `public_subnets` — Two public subnet IDs in different Availability Zones (e.g. `["subnet-0abc...", "subnet-0def..."]`). The ALB requires at least 2.

**Security Groups**

- `alb_sg_id` — Security group for the ALB. Must allow inbound traffic on ports 80 and 443 from `0.0.0.0/0`. Create it in EC2 → Security Groups.
- `app_sg_id` — An existing security group to attach to ECS tasks alongside the one Terraform creates. A minimal or default SG works if you have no extra rules to add.

**Secret**

- `app_secret_arn` — Full ARN of a secret in AWS Secrets Manager (e.g. `arn:aws:secretsmanager:us-east-1:123456789012:secret:my-app-secret-xxxxx`). Create the secret first, then paste its ARN here.

**Pre-requisites before running `terraform apply`**

1. `cojocloudsolutions.com` hosted zone must exist in Route53 in your AWS account.
2. Docker must be running locally — the ECR module builds and pushes the image during `terraform apply`.
3. A `./frontend` directory containing a `Dockerfile` must exist at the repo root.

All other variables (`region`, `environment`, `app_cpu`, `app_memory`, `image_tag`, `desired_count`) already have sensible defaults in the file.

---

> **Note:** Replace all placeholders in the Terraform script files before running the commands below.

```bash
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars -auto-approve
```

**From the output, copy the ALB DNS Endpoint:**

```
alb_dns_name = "alb-dev-ACCOUNT-ID.us-east-1.elb.amazonaws.com"
```

Navigate to that URL in your browser to verify the application is running.

> **Note:** Please wait a few minutes — ECS tasks can take time to reach **Running** status. Verify this from the AWS ECS Dashboard.

<img width="1901" height="1015" alt="image" src="https://github.com/user-attachments/assets/99e32eb6-5096-48e1-b0e0-eb965f505e32" />

**On the AWS Management Console, verify that all resources have been created:**

1. AWS ECR Repository and container images with proper tags
2. CloudWatch Log Group for ECS
3. IAM Role for ECS Task Execution and IAM policies
4. Security Group for ECS tasks
5. ECS Cluster
6. ALB + Target Group + Listener
7. ECS Task + Service (Fargate)

## Destroy All Resources

```bash
terraform destroy -var-file=dev.tfvars -auto-approve
```

> **Note:** Please make sure to destroy all resources to avoid unwanted costs.
