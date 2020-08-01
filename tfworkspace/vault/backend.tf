terraform {
  backend "local" {
    path = "../../tfstate/vault/terraform.tfstate"
  }
}
