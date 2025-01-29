resource "yandex_vpc_network" "data" {
  name = "data-net"
}

resource "yandex_vpc_subnet" "subnet-internet" {
  name           = "subnetinternet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.data.id
  v4_cidr_blocks = ["10.201.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet-web" {
  name           = "subnetweb"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.data.id
  v4_cidr_blocks = ["10.100.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet-db" {
  name           = "subnetdb"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.data.id
  v4_cidr_blocks = ["10.110.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet-manage" {
  name           = "subnetmanage"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.data.id
  v4_cidr_blocks = ["10.200.0.0/24"]
  route_table_id = yandex_vpc_route_table.bastion-route.id
}