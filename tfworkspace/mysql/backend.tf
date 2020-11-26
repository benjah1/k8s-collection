terraform {
  backend "local" {
    path = "../../tfstate/mysql/terraform.tfstate"
  }
}
