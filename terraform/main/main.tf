module "iam" {
  source = "../iam"
  yc_folder_id = var.yc_folder_id
  yc_service_account_name = var.yc_service_account_name
}

module "network" {
  source = "../network"
  yc_network_name = var.yc_network_name
  yc_subnet_name = var.yc_subnet_name
  yc_subnet_range = var.yc_subnet_range
  yc_zone = var.yc_zone
  yc_nat_gateway_name = var.yc_nat_gateway_name
  yc_route_table_name = var.yc_route_table_name
  yc_security_group_name = var.yc_security_group_name
}

module "storage" {
  source = "../storage"
  yc_bucket_name = var.yc_bucket_name
  yc_folder_id = var.yc_folder_id
  access_key = module.iam.access_key
  secret_key = module.iam.secret_key
}

module "dataproc" {
  source = "../dataproc"
  yc_dataproc_cluster_name = var.yc_dataproc_cluster_name
  yc_dataproc_version = var.yc_dataproc_version
  bucket_name = module.storage.bucket_name
  service_account_id = module.iam.service_accound_id
  subnet_id = module.network.subnet_id
  security_group_id = module.network.security_group_id
  yc_zone = var.yc_zone
  access_key = module.iam.access_key
  secret_key = module.iam.secret_key
  private_key_path = var.private_key_path
  public_key_path = var.public_key_path
  dataproc_data_resources = var.dataproc_data_resources
  dataproc_master_resources = var.dataproc_master_resources
  yc_folder_id = var.yc_folder_id
  yc_cloud_id = var.yc_cloud_id
  yc_token = var.yc_token
}