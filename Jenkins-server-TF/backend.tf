terraform {
  backend "s3" {
    bucket       = "newjagpoudelbucket"
    region       = "us-east-1"
    key          = "End-to-End-Kubernetes-DevSecOps-Tetris-Project/Jenkins-Server-TF/terraform.tfstate"
    
    # Resolves the "dynamodb_table is deprecated" warning
    use_lockfile = true 
    
    encrypt      = true
  }

  required_version = ">=0.13.0"

  required_providers {
    aws = {
      # Updated to 5.0+ to support the native S3 'use_lockfile' feature
      version = ">= 5.0.0" 
      source  = "hashicorp/aws"
    }
  }
}