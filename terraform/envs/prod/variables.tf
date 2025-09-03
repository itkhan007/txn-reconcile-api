variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM cert for HTTPS"
  type        = string
}

variable "container_image" {
  description = "ECR image for the service"
  type        = string
  default     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/txn-reconcile:prod"
}

variable "desired_count" {
  description = "Number of ECS tasks"
  type        = number
  default     = 3
}
