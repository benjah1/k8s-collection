terraform {
  required_providers {
    kubernetes = {
      versions = ["0.1"]
      source = "example.com/myorg/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_context   = "kind-kind"
}
