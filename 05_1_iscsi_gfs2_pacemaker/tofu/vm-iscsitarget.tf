
resource "yandex_compute_disk" "volumes" {
  count = 1
  name     = "disk-iscsitarget-${count.index + 1}"
  type     = "network-hdd"
  size     = 1
  zone     = "ru-central1-a"

}

resource "yandex_compute_instance" "iscsitarget" {
  depends_on = [resource.yandex_compute_disk.volumes]
  name = "otus-iscsitarget-${count.index + 1}"
  hostname="otus-iscsitarget-${count.index + 1}"
    platform_id = "standard-v1"
    count = 1

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
      name     = "boot-disk-iscsitarget-${count.index + 1}"
      size     = "10"
      #image_id = "fd8p9iv9fkpds5pueviu"
      image_id = data.yandex_compute_image.debian.image_id
    }
  }

  dynamic "secondary_disk" {
      for_each = yandex_compute_disk.volumes.*.id
          content {
              disk_id = secondary_disk.value
  
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



