terraform {
  backend "s3" {
    bucket         = "my-tfstate-stg"
    key            = "stg/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-stg"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "network" {
  source              = "../../modules/network"
  name                = "txn-stg"
  vpc_cidr            = "10.20.0.0/16"
  public_subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnet_cidrs= ["10.20.11.0/24", "10.20.12.0/24"]
  azs                 = ["us-east-1a", "us-east-1b"]
  tags = {
    Environment = "stg"
    Project     = "txn-reconcile"
    pci_scope   = "true"
  }
}

module "iam" {
  source = "../../modules/iam"
  name   = "txn-stg"
  tags   = { Environment = "stg" }
}

module "ecs" {
  source            = "../../modules/ecs_fargate"
  name              = "txn-stg"
  cluster_name      = "txn-stg-cluster"
  container_image   = var.container_image
  container_port    = 8080
  cpu               = 256
  memory            = 512
  desired_count     = var.desired_count
  execution_role_arn= module.iam.execution_role_arn
  task_role_arn     = module.iam.task_role_arn
  subnet_ids        = module.network.private_subnet_ids
  security_group_id = aws_security_group.ecs.id
  target_group_arn  = module.alb.target_group_arn
  region            = var.region
  secrets           = []
  tags              = { Environment = "stg" }
}

output "alb_dns" {
  value = module.alb.alb_dns_name
}
