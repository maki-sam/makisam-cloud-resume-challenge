terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  profile = "makisam" ## Update with your AWS Profile Name
  region  = "ap-southeast-1"
  default_tags {
    tags = {
      Owner   = "Makisam"
      Project = "Cloud Resume Challenge"
      Stage   = "Prod"
    }
  }
}