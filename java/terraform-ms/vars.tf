variable "namespace" {
  type = string
  default = "ms"
}

variable "name" {
  type = string
}

variable "profile" {
  type = string
}

variable "replicas" {
  type = number
  default = 1
}

variable "image" {
  type = string
}

variable "consul_addr" {
  type = string
}

variable "consul_token" {
  type = string
}

variable "vault_addr" {
  type = string
}

variable "vault_role_id" {
  type = string
}

variable "vault_secret_id" {
  type = string
}

variable "port" {
  type = number
}

