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
  region = "ap-south-1"
}

# ==========================================================
# EXISTING AWS NETWORKING
# These are read-only data sources.
# ==========================================================

data "aws_vpc" "default" {
  id = "vpc-0f45c6b3be3474d7e"
}

data "aws_subnet" "monitoring" {
  id = "subnet-0aeccfed4b61d4b78"
}

data "aws_security_group" "monitoring" {
  id = "sg-0b4f3ffc8d1844106"
}

data "aws_internet_gateway" "monitoring" {
  filter {
    name   = "attachment.vpc-id"
    values = ["vpc-0f45c6b3be3474d7e"]
  }
}

data "aws_route_table" "public" {
  route_table_id = "rtb-098d4805ca7b9c3a4"
}

# ==========================================================
# EXISTING EC2 INSTANCE
# Imported into Terraform
# ==========================================================

resource "aws_instance" "monitoring" {
  ami                         = "ami-07e5ce642bbc48c0d"
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.monitoring.id
  vpc_security_group_ids      = [data.aws_security_group.monitoring.id]
  key_name                    = "tera"
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true

    tags = {
      Name = "linux-server-monitor-root"
    }
  }

  tags = {
    Name = "linux-server-monitor"
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
