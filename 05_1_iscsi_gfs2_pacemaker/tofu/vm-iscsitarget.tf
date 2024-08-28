
resource "yandex_compute_disk" "volumes" {
  count = 1
  name     = "disk-iscsitarget-${count.index + 1}"
  type     = "network-hdd"
  size     = 1
  zone     = var.yc_zone

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
      image_id = data.yandex_compute_image.centos9.image_id
    }
  }

  dynamic "secondary_disk" {
      for_each = yandex_compute_disk.volumes.*.id
          content {
              disk_id = secondary_disk.value
  
      }   
  }


  network_interface  { 
      index = "0"
      subnet_id = yandex_vpc_subnet.subnet-3.id
      nat       = true
      ip_address = "10.100.0.254"
    
  }

  network_interface  {
    
      index = "1"
      subnet_id = yandex_vpc_subnet.subnet-1.id
      ip_address = "10.200.0.254"
  }

  network_interface  { 
      index = "2"
      subnet_id = yandex_vpc_subnet.subnet-2.id
      ip_address = "10.201.0.254"
    
  }


  metadata = {
    ssh-keys  = "devops:${file("~/.ssh/id_otus_ed25519.pub")}"
    user-data = "${file("cloud-init.yml")}"
    enable-oslogin = false
    serial-port-enable = 1
  }
}



