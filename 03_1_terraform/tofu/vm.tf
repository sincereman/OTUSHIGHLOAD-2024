resource "yandex_compute_instance" "nginx" {
  name = "otus-nginx-${count.index}"
  hostname="otus-nginx-${count.index}"
    platform_id = "standard-v1"
    count = 2

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

   
  boot_disk {
    initialize_params {
      name     = "boot-disk-nginx-${count.index}"
      size     = "10"
      image_id = "fd8p9iv9fkpds5pueviu"
    }
  }


  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_otus_ed25519.pub")}"
    user-data = "${file("metayc.yml")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}


