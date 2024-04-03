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
        owner = "AWS"
        maneged = "Terraform134"
      }
    }
  
}

resource "aws_vpc" "lab_vpc" {
 cidr_block = "10.0.0.0/16"
 tags = {
    Name = "Lab VPC"
 }
}

resource "aws_subnet" "public_subnet" {
 vpc_id     = aws_vpc.lab_vpc.id
 cidr_block = "10.0.1.0/24"
 availability_zone = "us-east-1a" # Substitua pela sua zona de disponibilidade desejada
 map_public_ip_on_launch = true
 tags = {
    Name = "Public Subnet"
 }
}

resource "aws_subnet" "private_subnet" {
 vpc_id     = aws_vpc.lab_vpc.id
 cidr_block = "10.0.2.0/24"
 availability_zone = "us-east-1a" # Substitua pela sua zona de disponibilidade desejada
 tags = {
    Name = "Private Subnet"
 }
}

resource "aws_internet_gateway" "lab_igw" {
 vpc_id = aws_vpc.lab_vpc.id
 tags = {
    Name = "Lab IGW"
 }
}

resource "aws_route_table" "public_route_table" {
 vpc_id = aws_vpc.lab_vpc.id
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
 }
 tags = {
    Name = "Public Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_association" {
 subnet_id      = aws_subnet.public_subnet.id
 route_table_id = aws_route_table.public_route_table.id
}