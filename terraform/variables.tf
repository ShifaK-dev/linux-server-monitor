variable "aws_region" {
  description = "AWS region where the infrastructure is located"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = "vpc-0f45c6b3be3474d7e"
}

variable "subnet_id" {
  description = "Existing monitoring subnet ID"
  type        = string
  default     = "subnet-0aeccfed4b61d4b78"
}

variable "security_group_id" {
  description = "Existing monitoring security group ID"
  type        = string
  default     = "sg-0b4f3ffc8d1844106"
}

variable "route_table_id" {
  description = "Existing public route table ID"
  type        = string
  default     = "rtb-098d4805ca7b9c3a4"
}

variable "ami_id" {
  description = "AMI ID for the monitoring EC2 instance"
  type        = string
  default     = "ami-07e5ce642bbc48c0d"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = "tera"
}

variable "instance_name" {
  description = "Name tag for the monitoring EC2"
  type        = string
  default     = "linux-server-monitor"
}

variable "root_volume_name" {
  description = "Name tag for the EC2 root volume"
  type        = string
  default     = "linux-server-monitor-root"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
}
