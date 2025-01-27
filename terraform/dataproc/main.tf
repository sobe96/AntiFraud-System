# Dataproc ресурсы
resource "yandex_dataproc_cluster" "dataproc_cluster" {
  bucket      = var.bucket_name
  description = "Dataproc Cluster created by Terraform for OTUS project"
  name        = var.yc_dataproc_cluster_name
  labels = {
    created_by = "terraform"
  }
  service_account_id = var.service_account_id
  zone_id            = var.yc_zone
  security_group_ids = [var.security_group_id]

  cluster_config {
    version_id = var.yc_dataproc_version

    hadoop {
      services = ["HDFS", "YARN", "SPARK"]
      properties = {
        "yarn:yarn.resourcemanager.am.max-attempts" = 5
      }
      ssh_public_keys = [file(var.public_key_path)]
    }

    subcluster_spec {
      name = "master"
      role = "MASTERNODE"
      resources {
        resource_preset_id = var.dataproc_master_resources.resource_preset_id
        disk_type_id       = "network-ssd"
        disk_size          = var.dataproc_master_resources.disk_size
      }
      subnet_id        = var.subnet_id
      hosts_count      = 1
      assign_public_ip = true
    }

    subcluster_spec {
      name = "data"
      role = "DATANODE"
      resources {
        resource_preset_id = var.dataproc_data_resources.resource_preset_id
        disk_type_id       = "network-ssd"
        disk_size          = var.dataproc_data_resources.disk_size
      }
      subnet_id   = var.subnet_id
      hosts_count = 1
      preemptible = true
    }
  }
}

resource "null_resource" "copy_data" {
  depends_on = [yandex_dataproc_cluster.dataproc_cluster]
  provisioner "local-exec" {
    command = <<EOT
      bash ./scripts/user_data.sh \
        --master_ip $(yc compute instance list --format json | jq -r '.[] | select(.labels.subcluster_role == "masternode") | .network_interfaces[].primary_v4_address.one_to_one_nat.address') \
        --access_key ${var.access_key} \
        --secret_key ${var.secret_key} \
        --s3_bucket ${var.bucket_name} \
        --token ${var.yc_token} \
        --cloud_id ${var.yc_cloud_id} \
        --folder_id ${var.yc_folder_id} \
        --private_key_path "${var.private_key_path}" \
        --upload_data_to_hdfs_content "$(cat scripts/upload_data_to_hdfs.sh | sed ':a;N;$!ba;s/\\n/\\\\n/g')" \
        >> provision.log 2>&1
      EOT
  }
}

data "external" "masternode_info" {
  program = ["zsh", "${path.root}/scripts/get_instance_info.sh"]
}