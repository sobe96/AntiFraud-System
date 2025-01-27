# Storage ресурсы
resource "yandex_storage_bucket" "data_bucket" {
  bucket        = "${var.yc_bucket_name}-${var.yc_folder_id}"
  access_key    = var.access_key
  secret_key    = var.secret_key
  force_destroy = true
  lifecycle {
    prevent_destroy = true
  }
}