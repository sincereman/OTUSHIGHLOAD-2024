
resource "yandex_compute_instance" "node" {
  depends_on = [resource.yandex_compute_instance.iscsitarget]
  name = "otus-node-${count.index + 1}"
  hostname="otus-node-${count.index + 1}"
    platform_id = "standard-v1"
    count = 3

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
      name     = "boot-disk-node-${count.index + 1}"
      size     = "10"
      #image_id = "fd8p9iv9fkpds5pueviu"
      image_id = data.yandex_compute_image.debian.image_id
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



