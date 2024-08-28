output "otus-iscsitarget"  {
  value       = [ 
    for i in yandex_compute_instance.iscsitarget :
    {
        name  = i.name
        id    = i.id
        fqdn  = i.fqdn
        public_ip = i.*.network_interface.0.nat_ip_address
        #link = "ssh devops@${i.*.network_interface.0.nat_ip_address} -i ~/.ssh/id_otus_ed25519"
        internal_data_ip = i.*.network_interface.0.ip_address        
        internal_iscsi_ip_1 = i.*.network_interface.1.ip_address
        internal_iscsi_ip_2 = i.*.network_interface.2.ip_address
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
        public_ip = i.*.network_interface.0.nat_ip_address
        #link = "ssh devops@".${i.*.network_interface.0.}." -i ~/.ssh/id_otus_ed25519"           
        internal_data_ip = i.*.network_interface.0.ip_address        
        internal_iscsi_ip_0 = i.*.network_interface.1.ip_address
        internal_iscsi_ip_1 = i.*.network_interface.2.ip_address 
    }
  ]
  description = "info-otus-node"
}