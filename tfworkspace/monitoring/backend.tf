terraform {
  backend "local" {
    path = "../../tfstate/monitoring/terraform.tfstate"
  }
}
