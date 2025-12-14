terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    backend "s3" {
        bucket         = "my-terraform-state-backend-unique-name-123"
        key            = "website-project/terraform.tfstate"
        region         = "eu-north-1"
        encrypt        = true                             
        dynamodb_table = "terraform-locks-table"  
    }
}


provider "aws" {
    region = "eu-north-1"
}