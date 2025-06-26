terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.9"
    }
  }


  backend "s3" {
    bucket  = "state-tf-infra"
    key     = "test/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "test-subnet"
  }
}

resource "aws_security_group" "test_sg" {
  name        = "test-sg"
  description = "Test security group"
  vpc_id      = aws_vpc.test_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-sg"
  }
}

resource "aws_instance" "test_instance" {
  ami                    = "ami-0c7217cdde317cfec" # Amazon Linux 2023 AMI in us-east-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.test_subnet.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]

  tags = {
    Name = "test-instance"
  }
}

output "test_instance_id" {
  description = "ID of the test EC2 instance"
  value       = aws_instance.test_instance.id
}

output "test_public_ip" {
  description = "Public IP address of the test instance"
  value       = aws_instance.test_instance.public_ip
}