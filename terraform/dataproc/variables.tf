variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
}

variable "yc_zone" {
  type        = string
  description = "Zone for Yandex Cloud resources"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket"
}

variable "service_account_id" {
  type = string
  description = "Service account ID"
}

variable "subnet_id" {
  type = string
  description = "Subnet ID"
}

variable "security_group_id" {
  type = string
  description = "Security group ID"
}

variable "access_key" {
  type = string
  description = "Access key"
}

variable "secret_key" {
  type = string
  description = "Secret key"
}

variable "private_key_path" {
  type = string
  description = "Private SSH key path"
}

variable "yc_dataproc_cluster_name" {
  type        = string
  description = "Name of the Dataproc cluster"
}

variable "yc_dataproc_version" {
  type        = string
  description = "Version of Dataproc"
}

variable "public_key_path" {
  type        = string
  description = "Path to the public key file"
}

variable "dataproc_master_resources" {
  type = object({
    resource_preset_id = string
    disk_type_id       = string
    disk_size          = number
  })
  default = {
    resource_preset_id = "s3-c2-m8"
    disk_type_id       = "network-ssd"
    disk_size          = 40
  }
}

variable "dataproc_data_resources" {
  type = object({
    resource_preset_id = string
    disk_type_id       = string
    disk_size          = number
  })
  default = {
    resource_preset_id = "s3-c4-m16"
    disk_type_id       = "network-ssd"
    disk_size          = 128
  }
}
