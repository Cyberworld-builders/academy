terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
    backend "s3" {
        bucket = "wsa-terraform-remote-state"
        key = "secops/vpn.tfstate"
        region = "ap-southeast-2"
    }
}

provider "aws" {
    region = "ap-southeast-2"
}

data "aws_caller_identity" "current" {}

resource "random_string" "suffix" {
    length = 8
    special = false
    upper = false
}