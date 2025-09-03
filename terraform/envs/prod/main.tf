terraform {
  backend "s3" {
    bucket         = "my-tfstate-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-prod"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source              = "../../modules/network"
  name                = "txn-prod"
  vpc_cidr            = "10.30.0.0/16"
  public_subnet_cidrs = ["10.30.1.0/24", "10.30.2.0/24"]
  private_subnet_cidrs= ["10.30.11.0/24", "10.30.12.0/24"]
  azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  tags = {
    Environment = "prod"
    Project     = "txn-reconcile"
    pci_scope   = "true"
  }
}

module "iam" {
  source = "../../modules/iam"
  name   = "txn-prod"
  tags   = { Environment = "prod" }
}

module "ecs" {
  source            = "../../modules/ecs_fargate"
  name              = "txn-prod"
  cluster_name      = "txn-prod-cluster"
  container_image   = var.container_image
  container_port    = 8080
  cpu               = 512
  memory            = 1024
  desired_count     = var.desired_count
  execution_role_arn= module.iam.execution_role_arn
  task_role_arn     = module.iam.task_role_arn
  subnet_ids        = module.network.private_subnet_ids
  security_group_id = aws_security_group.ecs.id
  target_group_arn  = module.alb.target_group_arn
  region            = var.region
  secrets           = []
  tags              = { Environment = "prod" }
}

output "alb_dns" {
  value = module.alb.alb_dns_name
}
