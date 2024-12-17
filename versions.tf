terraform {

  required_version = "~> 1.5.7"

  required_providers {
    aws = {
      version               = ">= 4.0"
      source                = "hashicorp/aws"
      configuration_aliases = [aws.ct-management]
    }

    tls = {
      version = "~> 4.0"
      source  = "hashicorp/tls"
    }

    null = {
      version = "~> 3.0"
      source  = "hashicorp/null"
    }

    local = {
      version = "~> 2.0"
      source  = "hashicorp/local"
    }

    random = {
      version = "~> 3.0"
      source  = "hashicorp/random"
    }


  }

}
