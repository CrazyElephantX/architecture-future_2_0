variable "env_name" {
  description = "Имя окружения (dev/test/prod/local)"
  type        = string
  default     = "dev"
}

variable "env_octet" {
  description = "Число (0-255) для мок-IP адресов"
  type        = number
  default     = 42
}

variable "vpc_cidr" {
  description = "Мок-CIDR VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "subnets" {
  description = "Карта подсетей и их CIDR"
  type = map(object({
    cidr  = string
    az    = string
  }))
  default = {
    app    = { cidr = "10.42.10.0/24", az = "az-a" }
    data   = { cidr = "10.42.20.0/24", az = "az-b" }
    secure = { cidr = "10.42.30.0/24", az = "az-c" }
    mgmt   = { cidr = "10.42.40.0/24", az = "az-a" }
  }
}

variable "subnet_octets" {
  description = "Второй октет для мок-IP по подсети"
  type        = map(number)
  default = {
    app    = 10
    data   = 20
    secure = 30
    mgmt   = 40
  }
}

variable "enable_nat" {
  description = "Включить мок-NAT"
  type        = bool
  default     = true
}

variable "default_vm_size" {
  description = "Размер по умолчанию"
  type = object({
    cpu     = number
    ram_gb  = number
    disk_gb = number
  })
  default = {
    cpu     = 2
    ram_gb  = 4
    disk_gb = 40
  }
}

variable "vm_size_by_role" {
  description = "Размеры по ролям"
  type = map(object({
    cpu     = number
    ram_gb  = number
    disk_gb = number
  }))
  default = {
    kafka      = { cpu = 4, ram_gb = 8,  disk_gb = 200 }
    clickhouse = { cpu = 8, ram_gb = 32, disk_gb = 500 }
    flink      = { cpu = 4, ram_gb = 16, disk_gb = 100 }
    camel      = { cpu = 2, ram_gb = 8,  disk_gb = 40 }
    minio      = { cpu = 4, ram_gb = 16, disk_gb = 200 }
    superset   = { cpu = 2, ram_gb = 4,  disk_gb = 40 }
    deid       = { cpu = 2, ram_gb = 8,  disk_gb = 80 }
    mdm        = { cpu = 2, ram_gb = 8,  disk_gb = 80 }
  }
}

variable "kafka_count" {
  type        = number
  description = "Количество брокеров Kafka"
  default     = 3
}

variable "clickhouse_count" {
  type        = number
  description = "Количество узлов ClickHouse"
  default     = 3
}

variable "flink_count" {
  type        = number
  description = "Количество узлов Flink"
  default     = 2
}

variable "camel_count" {
  type        = number
  description = "Количество узлов Apache Camel"
  default     = 2
}

variable "minio_count" {
  type        = number
  description = "Количество узлов MinIO"
  default     = 2
}