terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

# ==========================================================
# EXISTING AWS NETWORKING
# These are read-only data sources.
# ==========================================================

data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_subnet" "monitoring" {
  id = var.subnet_id
}

data "aws_security_group" "monitoring" {
  id = var.security_group_id
}

data "aws_internet_gateway" "monitoring" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_route_table" "public" {
  route_table_id = var.route_table_id
}

# ==========================================================
# EXISTING EC2 INSTANCE
# Imported into Terraform
# ==========================================================

module "monitoring" {
  source = "./modules/ec2"

  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = data.aws_subnet.monitoring.id
  security_group_id = data.aws_security_group.monitoring.id
  key_name          = var.key_name
  instance_name     = var.instance_name
  root_volume_name  = var.root_volume_name
  root_volume_size  = var.root_volume_size
  root_volume_type  = var.root_volume_type
}

# ==========================================================
# OUTPUTS
# ==========================================================

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "vpc_cidr" {
  value = data.aws_vpc.default.cidr_block
}

output "subnet_id" {
  value = data.aws_subnet.monitoring.id
}

output "subnet_cidr" {
  value = data.aws_subnet.monitoring.cidr_block
}

output "subnet_az" {
  value = data.aws_subnet.monitoring.availability_zone
}

output "security_group_id" {
  value = data.aws_security_group.monitoring.id
}

output "security_group_name" {
  value = data.aws_security_group.monitoring.name
}

output "internet_gateway_id" {
  value = data.aws_internet_gateway.monitoring.id
}

output "route_table_id" {
  value = data.aws_route_table.public.id
}

output "instance_id" {
  value = module.monitoring.instance_id
}

output "instance_private_ip" {
  value = module.monitoring.private_ip
}

output "instance_public_ip" {
  value = module.monitoring.public_ip
}
moved {
  from = aws_instance.monitoring
  to   = module.monitoring.aws_instance.monitoring
}
