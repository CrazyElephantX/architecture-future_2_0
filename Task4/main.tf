terraform {
  required_version = ">= 1.5.0"
}

locals {
  artifact_dir = "${path.module}/artifacts/${var.env_name}"

  vm_groups = {
    kafka = {
      count  = var.kafka_count
      subnet = "data"
    }
    clickhouse = {
      count  = var.clickhouse_count
      subnet = "data"
    }
    flink = {
      count  = var.flink_count
      subnet = "app"
    }
    camel = {
      count  = var.camel_count
      subnet = "app"
    }
    minio = {
      count  = var.minio_count
      subnet = "data"
    }
    superset = {
      count  = 1
      subnet = "app"
    }
    deid = {
      count  = 1
      subnet = "secure"
    }
    mdm = {
      count  = 1
      subnet = "app"
    }
  }

  vms = flatten([
    for role, cfg in local.vm_groups : [
      for i in range(cfg.count) : {
        name    = format("%s-%s-%02d", var.env_name, role, i + 1)
        role    = role
        subnet  = cfg.subnet
        ip      = format("10.%d.%d.%d", var.env_octet, var.subnet_octets[cfg.subnet], i + 10)
        cpu     = lookup(var.vm_size_by_role, role, var.default_vm_size).cpu
        ram_gb  = lookup(var.vm_size_by_role, role, var.default_vm_size).ram_gb
        disk_gb = lookup(var.vm_size_by_role, role, var.default_vm_size).disk_gb
      }
    ]
  ])

  inventory_yaml = yamlencode({
    env      = var.env_name
    vpc_cidr = var.vpc_cidr
    nat      = var.enable_nat
    subnets  = var.subnets
    vms = [
      for vm in local.vms : {
        name    = vm.name
        role    = vm.role
        subnet  = vm.subnet
        ip      = vm.ip
        cpu     = vm.cpu
        ram_gb  = vm.ram_gb
        disk_gb = vm.disk_gb
      }
    ]
  })
}

resource "terraform_data" "artifacts_dir" {
  input = {
    path = local.artifact_dir
  }

  provisioner "local-exec" {
    command = "mkdir -p ${self.input.path} ${self.input.path}/vms ${self.input.path}/network"
    interpreter = ["bash", "-lc"]
  }
}

resource "terraform_data" "network" {
  triggers_replace = [
    var.vpc_cidr,
    jsonencode(var.subnets),
    tostring(var.enable_nat),
  ]

  depends_on = [terraform_data.artifacts_dir]

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<EOT
cat > "${local.artifact_dir}/network/vpc.txt" <<EOF
VPC CIDR: ${var.vpc_cidr}
Subnets:  ${jsonencode(var.subnets)}
NAT:      ${var.enable_nat}
EOF
EOT
  }
}

resource "terraform_data" "nat" {
  count = var.enable_nat ? 1 : 0

  depends_on = [terraform_data.network]

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<EOT
cat > "${local.artifact_dir}/network/nat.txt" <<EOF
NAT: enabled
Outbound only, no public inbound.
EOF
EOT
  }
}

resource "terraform_data" "vm" {
  for_each = { for vm in local.vms : vm.name => vm }

  depends_on = [terraform_data.network]

  input = each.value

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<EOT
dir="${local.artifact_dir}/vms/${self.input.name}"
mkdir -p "$dir"
cat > "$dir/meta.txt" <<EOF
name=${self.input.name}
role=${self.input.role}
subnet=${self.input.subnet}
ip=${self.input.ip}
cpu=${self.input.cpu}
ram_gb=${self.input.ram_gb}
disk_gb=${self.input.disk_gb}
EOF
EOT
  }
}

resource "terraform_data" "inventory" {
  triggers_replace = [sha1(local.inventory_yaml)]
  depends_on       = [terraform_data.vm]

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<EOT
cat > "${local.artifact_dir}/inventory.yaml" <<'EOF'
${local.inventory_yaml}
EOF
echo "Inventory written to ${local.artifact_dir}/inventory.yaml"
EOT
  }
}

resource "terraform_data" "publish" {
  depends_on = [terraform_data.inventory]

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = "echo 'Artifacts ready at: ${local.artifact_dir}'"
  }
}

output "artifact_dir" {
  description = "Путь к локальным артефактам (инвентарь, мок-конфиги)"
  value       = local.artifact_dir
}

output "vm_ips_by_role" {
  description = "Список IP по ролям (моки)"
  value = {
    for role, _ in local.vm_groups :
    role => [for vm in local.vms : vm.ip if vm.role == role]
  }
}

output "inventory_yaml" {
  description = "Готовый inventory.yaml"
  value       = local.inventory_yaml
}