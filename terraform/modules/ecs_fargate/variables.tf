variable "name" {}
variable "cluster_name" {}
variable "container_image" {}
variable "container_port" { type = number }
variable "cpu" { type = number }
variable "memory" { type = number }
variable "desired_count" { type = number }
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "subnet_ids" { type = list(string) }
variable "security_group_id" {}
variable "target_group_arn" {}
variable "region" {}
variable "secrets" { type = list(any) }
variable "tags" { type = map(string) }
