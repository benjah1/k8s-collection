terraform {
  backend "local" {
    path = "../../tfstate/kafka/terraform.tfstate"
  }
}
