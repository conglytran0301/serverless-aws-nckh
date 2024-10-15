provider "aws" {
  region = "us-east-1" # Adjust the region as necessary
}

variable "cloud9_cidr_block" {
  description = "The CIDR block range for your Cloud9 IDE VPC"
  default     = "10.43.0.0/28"
}

resource "aws_vpc" "main" {
  cidr_block           = var.cloud9_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cloud9_cidr_block}-VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cloud9_cidr_block}-InternetGateway"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cloud9_cidr_block}-RouteTable"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cloud9_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.cloud9_cidr_block}-PublicSubnet1"
  }
}

resource "aws_route_table_association" "public_subnet_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.main.id
}

data "aws_availability_zones" "available" {}

resource "aws_cloud9_environment_ec2" "dev_env" {
  instance_type               = "t3.small"
  name                        = "Development Environment"
  subnet_id                   = aws_subnet.public_subnet_1.id
  automatic_stop_time_minutes = 30
}
