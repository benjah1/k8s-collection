terraform {
  backend "local" {
    path = "../../tfstate/ms/terraform.tfstate"
  }

  required_providers {
    mysql = {
      source  = "terraform-providers/mysql"
    }
  }
}
