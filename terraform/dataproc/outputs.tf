output "dataproc_cluster_id" {
  value = yandex_dataproc_cluster.dataproc_cluster.id
}

output "master_node_ip_command" {
  value = data.external.masternode_info.result.ip
}