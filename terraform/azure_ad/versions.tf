terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1"
    }
  }
}

provider "azurerm" {
  features {}

  # FXCI Azure dev/test Subscription
  subscription_id = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}
