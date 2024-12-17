terraform {

  required_version = "~> 1.5.7"

  required_providers {
    aws = {
      version = ">= 4.0"
      source  = "hashicorp/aws"
    }

    random = {
      version = "~> 3.0"
      source  = "hashicorp/random"
    }


  }

}
