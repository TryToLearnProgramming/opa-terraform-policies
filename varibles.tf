variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "my-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0866a3c8686eaeeba"  # Ubuntu 24.04 LTS AMI (HVM), SSD Volume Type
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "my-key-pair"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    "Terraform" = "true",
    "OU" = "POC",
    "BU" = "POC",
    "PU" = "POC",
    "project_name" = "terraform-poc",
    "environment" = "dev"
    # opa-compliance-check = "false"
  }
}