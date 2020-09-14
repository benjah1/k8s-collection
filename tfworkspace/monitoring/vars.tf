variable "es_resource_cpu" {
  type = string
  default = "1000m"
}

variable "es_resource_memory" {
  type = string
  default = "4Gi"
}

variable "es_heap_size" {
  type = string
  default = "-Xmx3g -Xms3g"
}

variable "es_image_busybox" {
  type = string
  default = "busybox:1.31.1"
}

variable "es_image_elasticsearch" {
  type = string
  default = "elasticsearch:7.8.0"
}
