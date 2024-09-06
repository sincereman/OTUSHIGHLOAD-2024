resource "yandex_lb_target_group" "frontend" {
  name      = "nlbfrontend"
  target {
    subnet_id = yandex_vpc_subnet.subnet-web.id
    address   = yandex_compute_instance.frontend.0.network_interface.0.ip_address 
  }
  target {
    subnet_id = yandex_vpc_subnet.subnet-web.id
    address   = yandex_compute_instance.frontend.1.network_interface.0.ip_address 
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name = "nlb"
  #deletion_protection = "true"
  listener {
    name = "http"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.frontend.id
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/" #frontvip
      }
    }
  }
}

