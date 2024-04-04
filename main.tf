terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "4.60.0"
  }
}
}

provider "aws" {
    region = "us-east-1"
    shared_config_files = [ "C:/Users/46683590842/.aws/config"  ]
    shared_credentials_files = [ "C:/Users/46683590842/.aws/credentials" ]

    default_tags {
      tags = {
        owner = "Marcelo"
        maneged = "Terraform134"
      }
    }
  
}

# VPC
resource "aws_vpc" "VPC-CloudPlay" {
  cidr_block           = "172.18.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name = "VPC-CloudPlay"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "IGW-CloudPlay" {
  vpc_id = aws_vpc.VPC-CloudPlay.id

  tags = {
    Name = "IGW-CloudPlay"
  }
}

# SUBNET Subrede-Pub1
resource "aws_subnet" "Subrede-Pub1" {
  vpc_id                  = aws_vpc.VPC-CloudPlay.id
  cidr_block              = "172.18.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Subrede-Pub1"
  }
}

# SUBNET Subrede-Pub2
resource "aws_subnet" "Subrede-Pub2" {
  vpc_id            = aws_vpc.VPC-CloudPlay.id
  cidr_block        = "172.18.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subrede-Pub2"
  }
}

# SUBNET Subrede-Pri1
resource "aws_subnet" "Subrede-Pri1" {
  vpc_id                  = aws_vpc.VPC-CloudPlay.id
  cidr_block              = "172.18.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Subrede-Pri1"
  }
}

# SUBNET Subrede-Pri2
resource "aws_subnet" "Subrede-Pri2" {
  vpc_id            = aws_vpc.VPC-CloudPlay.id
  cidr_block        = "172.18.4.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subrede-Pri2"
  }
}

# ROUTE TABLE Publica
resource "aws_route_table" "Rotas-CloudPlay-Pub" {
  vpc_id = aws_vpc.VPC-CloudPlay.id
  

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW-CloudPlay.id
  }

  tags = {
    Name = "Rotas-CloudPlay-Pub"
  }
}

# ROUTE TABLE Privada
resource "aws_route_table" "Rotas-CloudPlay-Pri" {
  vpc_id = aws_vpc.VPC-CloudPlay.id

  tags = {
    Name = "Rotas-CloudPlay-Pri"
  }
}

# SUBNET ASSOCIATION Pub
resource "aws_route_table_association" "Subrede-Pub1" {
  subnet_id      = aws_subnet.Subrede-Pub1.id
  route_table_id = aws_route_table.Rotas-CloudPlay-Pub.id
}
resource "aws_route_table_association" "Subrede-Pub2" {
  subnet_id      = aws_subnet.Subrede-Pub2.id
  route_table_id = aws_route_table.Rotas-CloudPlay-Pub.id
}

resource "aws_route_table_association" "Subrede-Pri1" {
  subnet_id      = aws_subnet.Subrede-Pri1.id
  route_table_id = aws_route_table.Rotas-CloudPlay-Pub.id
}
resource "aws_route_table_association" "Subrede-Pri2" {
  subnet_id      = aws_subnet.Subrede-Pri1.id
  route_table_id = aws_route_table.Rotas-CloudPlay-Pub.id
}