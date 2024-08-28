resource "yandex_vpc_network" "iscsi-net" {
  name = "iscsi-net"
}
resource "yandex_vpc_network" "data" {
  name = "data"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.iscsi-net.id
  v4_cidr_blocks = ["10.200.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.iscsi-net.id
  v4_cidr_blocks = ["10.201.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = "subnet3"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.data.id
  v4_cidr_blocks = ["10.100.0.0/24"]
}