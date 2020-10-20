variable "consul_addr" {
  type = string
  default = "192.168.51.103"
}

variable "vault_addr" {
  type = string
  default = "192.168.51.103"
}

variable "consul_token" {
  type = string
  default = "7b52b70e-3cb3-2e0d-baa4-4b58659336d6"
}

variable "vault_token" {
  type = string
  default = "s.wKwep8VyxvEcFvVAoC6vvoLY"
}

variable "mysql_addr" {
  type = string
  default = "192.168.51.103:3306"
}

variable "mysql_user" {
  type = string
  default = "root"
}

variable "mysql_pass" {
  type = string
  default = "12345"
}

variable "kafka_bootstrap_server" {
  type = string
  default = "192.168.51.103:9092"
}

variable "gitlab_reg_host" {
  type = string
  default = "192.168.0.76:38081"
}

variable "gitlab_reg_user" {
  type = string
  default = "root"
}

variable "gitlab_reg_pass" {
  type = string
  default = "123456789"
}


