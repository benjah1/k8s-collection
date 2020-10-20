variable "namespace" {
  type = string
  default = "monitoring"
}

variable "replicas" {
  type = number
  default = 3
}

variable "consul_token" {
  type = string
}
