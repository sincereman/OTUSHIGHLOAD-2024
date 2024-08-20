
output "internal_ip_address_iscsitarget" {
  value = yandex_compute_instance.iscsitarget.*.network_interface.0.ip_address
}

output "external_ip_address_iscsitarget" {
  value = yandex_compute_instance.iscsitarget.*.network_interface.0.nat_ip_address
}

output "otus-nodes"  {
  value       = [ 
    for i in yandex_compute_instance.node :
    {
        name  = i.name
        id    = i.id
        fqdn  = i.fqdn
        internal_ip = i.*.network_interface.0.ip_address
        public_ip = i.*.network_interface.0.nat_ip_address
    }
  ]
  description = "info-otus-node"
}