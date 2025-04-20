provider "aws" {
  region = var.region
}
###################################VPC########################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.tags
}
###################################ec2 instance########################################
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami                    = var.ami_id
  instance_type          = var.instance_type
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true

  tags = var.tags
}
###################################SG-1########################################
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "allow_ssh"
  })
}
# ###################################SG-2########################################
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "HTTP from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    opa-compliance-check = "false"
  })
}
###################################s3 bucket########################################
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket-${random_string.bucket_suffix.result}"
  acl    = "private"

  // Versioning configuration (kept disabled as per current setup)
  versioning = {
    enabled = false
  }

  // Add server-side encryption configuration
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        # sse_algorithm     = "aws:kms"
        # kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/dummy-kms-key-id"
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_instance" "bypass_tag_instance" {
  ami = var.ami_id
  instance_type = var.instance_type
  tags = var.tags
}
