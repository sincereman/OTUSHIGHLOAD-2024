output "otus-iscsitarget"  {
  value       = [ 
    for i in yandex_compute_instance.iscsitarget :
    {
        name  = i.name
        id    = i.id
        fqdn  = i.fqdn
        internal_ip_0 = i.*.network_interface.0.ip_address
        internal_ip_1 = i.*.network_interface.1.ip_address
        public_ip = i.*.network_interface.0.nat_ip_address
    }
  ]
  description = "info-otus-node"
}


output "otus-nodes"  {
  value       = [ 
    for i in yandex_compute_instance.node :
    {
        name  = i.name
        id    = i.id
        fqdn  = i.fqdn
        internal_ip_0 = i.*.network_interface.0.ip_address
        internal_ip_1 = i.*.network_interface.1.ip_address        
        public_ip = i.*.network_interface.0.nat_ip_address
    }
  ]
  description = "info-otus-node"
}