env_name   = "dev"
env_octet  = 42
vpc_cidr   = "10.42.0.0/16"
enable_nat = true

# vm_size_by_role = {
#   kafka      = { cpu = 4, ram_gb = 8,  disk_gb = 200 }
#   clickhouse = { cpu = 8, ram_gb = 32, disk_gb = 500 }
#   flink      = { cpu = 4, ram_gb = 16, disk_gb = 100 }
#   camel      = { cpu = 2, ram_gb = 8,  disk_gb = 40 }
#   minio      = { cpu = 4, ram_gb = 16, disk_gb = 200 }
#   superset   = { cpu = 2, ram_gb = 4,  disk_gb = 40 }
#   deid       = { cpu = 2, ram_gb = 8,  disk_gb = 80 }
#   mdm        = { cpu = 2, ram_gb = 8,  disk_gb = 80 }
# }