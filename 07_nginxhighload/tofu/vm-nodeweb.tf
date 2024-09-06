resource "yandex_compute_instance" "nodeweb" {
  depends_on = [resource.yandex_compute_instance.bastion]
  name = "otus-nodeweb-${count.index + 1}"
  hostname="otus-nodeweb-${count.index + 1}"
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
      name     = "boot-disk-nodeweb-${count.index + 1}"
      size     = "10"
      #image_id = "fd8p9iv9fkpds5pueviu"
      image_id = data.yandex_compute_image.debian12.image_id
    }
  }

  network_interface  { 
      index = "0"
      subnet_id = yandex_vpc_subnet.subnet-manage.id
      ip_address = "10.200.0.${count.index + 10}"
      security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }

  network_interface  { 
      index = "1"
      subnet_id = yandex_vpc_subnet.subnet-web.id
      ip_address = "10.100.0.${count.index + 10}"
  }

  network_interface {
      index = "2"    
      subnet_id = yandex_vpc_subnet.subnet-db.id
      ip_address = "10.110.0.${count.index + 10}"
  }

  


  metadata = {
    ssh-keys  = "devops:${file("~/.ssh/id_otus_ed25519.pub")}"
    user-data = "${file("cloud-init.yml")}"
  }
}



