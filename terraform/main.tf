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

resource "aws_instance" "monitoring" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.monitoring.id
  vpc_security_group_ids      = [data.aws_security_group.monitoring.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true

    tags = {
      Name = var.root_volume_name
    }
  }

  tags = {
    Name = var.instance_name
  }
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
  value = aws_instance.monitoring.id
}

output "instance_private_ip" {
  value = aws_instance.monitoring.private_ip
}

output "instance_public_ip" {
  value = aws_instance.monitoring.public_ip
}
