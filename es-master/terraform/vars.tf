variable "namespace" {
  type = string
  default = "monitoring"
}

variable "replicas" {
  type = number
  default = 3
}

variable "resource_cpu" {
  type = string
  default = "1000m"
}

variable "resource_memory" {
  type = string
  default = "4Gi"
}

variable "heap_size" {
  type = string
  default = "-Xmx3g -Xms3g"
}

variable "image_busybox" {
  type = string
  default = "busybox:1.31.1"
}

variable "image_elasticsearch" {
  type = string
  default = "elasticsearch:7.8.0"
}
