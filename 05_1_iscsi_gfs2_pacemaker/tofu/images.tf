data "yandex_compute_image" "debian12" {
  family = var.debian12
}

data "yandex_compute_image" "centos9" {
  family = var.centos9
}