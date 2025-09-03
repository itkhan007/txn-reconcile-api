terraform {
  backend "s3" {
    bucket         = "my-tfstate-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile = true
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "network" {
  source              = "../../modules/network"
  name                = "txn-dev"
  vpc_cidr            = "10.10.0.0/16"
  public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs= ["10.10.11.0/24", "10.10.12.0/24"]
  azs                 = ["us-east-1a", "us-east-1b"]
  tags = {
    Environment = "dev"
    Project     = "txn-reconcile"
    pci_scope   = "true"
  }
}

module "iam" {
  source = "../../modules/iam"
  name   = "txn-dev"
  tags   = { Environment = "dev" }
}

# TODO: Security groups, ALB, ECS wiring

output "alb_dns" {
  value = module.alb.alb_dns_name
}
