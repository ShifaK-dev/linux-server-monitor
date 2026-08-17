variable "aws_region" {
  description = "AWS region where the infrastructure is located"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Existing monitoring subnet ID"
  type        = string
}

variable "security_group_id" {
  description = "Existing monitoring security group ID"
  type        = string
}

variable "route_table_id" {
  description = "Existing public route table ID"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the monitoring EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the monitoring EC2"
  type        = string
}

variable "root_volume_name" {
  description = "Name tag for the EC2 root volume"
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
}
