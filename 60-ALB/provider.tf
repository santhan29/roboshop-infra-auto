terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }

  backend "s3" {    #here backend means state
    bucket = "81s-remotestate-dev" 
    key    = "expense-alb-jenkins"  
    region = "us-east-1"
    dynamodb_table = "81s-locking-development"
  }
}


provider "aws" {
  # Configuration options
  region = "us-east-1"
} 


 