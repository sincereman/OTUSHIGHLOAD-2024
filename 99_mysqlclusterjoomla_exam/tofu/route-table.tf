# Creating a route table and static route

resource "yandex_vpc_route_table" "bastion-route" {
  name       = "bastion-route"
  network_id = yandex_vpc_network.data.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.bastion[0].network_interface.0.ip_address
  }
}

