terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "vega-course-terraform"
  default_tags {
    tags = {
      Owner = "Stefan Arađanin"
    }
  }
}


