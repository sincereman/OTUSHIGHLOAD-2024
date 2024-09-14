output "otus-bastion"  {
  value       = [ 
    for i in yandex_compute_instance.bastion :
    {
        name  = i.name
        id    = i.id
        fqdn  = i.fqdn
        public_ip = i.*.network_interface.0.nat_ip_address
        #link = "ssh devops@${i.*.network_interface.0.nat_ip_address} -i ~/.ssh/id_otus_ed25519"
        internal_data_ip_manage = i.*.network_interface.0.ip_address        

    }
  ]
  description = "info-frontend-node"
}

output "otus-frontend"  {
  value       = [ 
    for i in yandex_compute_instance.frontend :
    {
        name  = i.name
        id    = i.id
        fqdn  = i.fqdn
        public_ip = i.*.network_interface.0.nat_ip_address
        #link = "ssh devops@${i.*.network_interface.0.nat_ip_address} -i ~/.ssh/id_otus_ed25519"
        internal_data_ip_manage = i.*.network_interface.1.ip_address  
        internal_data_ip_web = i.*.network_interface.0.ip_address 
      

    }
  ]
  description = "info-frontend-node"
}

output "otus-nodeweb"  {
  value       = [ 
    for i in yandex_compute_instance.nodeweb :
    {
        name  = i.name
        id    = i.id
        fqdn  = i.fqdn
        #link = "ssh devops@".${i.*.network_interface.0.}." -i ~/.ssh/id_otus_ed25519"   
        internal_data_ip_manage = i.*.network_interface.0.ip_address     
        internal_data_ip_web = i.*.network_interface.1.ip_address        
        internal_data_ip_db = i.*.network_interface.2.ip_address
    }
  ]
  description = "info-web-node"
}

output "otus-nodedb"  {
  value       = [ 
    for i in yandex_compute_instance.nodedb :
    {
        name  = i.name
        id    = i.id
        fqdn  = i.fqdn
        #link = "ssh devops@".${i.*.network_interface.0.}." -i ~/.ssh/id_otus_ed25519"  
        internal_data_ip_manage = i.*.network_interface.0.ip_address           
        internal_data_ip_db = i.*.network_interface.1.ip_address        
    }
  ]
  description = "info-db-node"

}


output "lb_ip_address" {
  value = yandex_lb_network_load_balancer.nlb.listener.*
}  