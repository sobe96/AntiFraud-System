# Выходные данные
output "bucket_name" {
  value = module.storage.bucket_name
}

output "master_node_ip_command" {
  value = module.dataproc.master_node_ip_command
}