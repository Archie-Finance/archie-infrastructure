module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "rabbitmq-security-group"
  description = "RabbitMQ security group"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      description = "RabbitMQ from within VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_mq_broker" "rabbitmq" {
  broker_name = var.name

  engine_type = "RabbitMQ"
  engine_version = "3.9.16"

  host_instance_type = var.host_instance_type

  user {
    username = "user"
    password = random_password.password.result
  }

  security_groups = [module.security_group.security_group_id]
  subnet_ids = var.vpc_private_subnets

  deployment_mode = "CLUSTER_MULTI_AZ"
}