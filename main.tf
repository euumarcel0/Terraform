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

