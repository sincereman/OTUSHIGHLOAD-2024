
output "internal_ip_address_nginx" {
  value = yandex_compute_instance.nginx.*.network_interface.0.ip_address
}

output "external_ip_address_nginx" {
  value = yandex_compute_instance.nginx.*.network_interface.0.nat_ip_address
}

# Generate inventory file for Ansible
resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/01_nginx/inventories/hosts"
  file_permission  = "0644"

  content = templatefile("${path.module}/templates/inventory.tpl", {
      nginx_name                = yandex_compute_instance.nginx.*.name,
      nginx_external_ip_address = yandex_compute_instance.nginx.*.network_interface.0.nat_ip_address,
      nginx_internal_ip_address = yandex_compute_instance.nginx.*.network_interface.0.ip_address,
#    ip_addrs = google_compute_instance.andrdi-gcp-server[*].network_interface[0].access_config[0].nat_ip
  })



#Wait SSH

#v1
# provisioner "local-exec" {
#    command = "${path.module}/tofu/scripts/waitssh.sh ${yandex_compute_instance.nginx[0].network_interface.0.nat_ip_address}"
#  }

#v2


#  provisioner "remote-exec" {
#    inline = ["uname -a"]
#
#    connection {
#      type        = "ssh"
#      host        = yandex_compute_instance.nginx[2].*.network_interface.0.nat_ip_address
#      user        = "devops"
#      private_key = "ubuntu:${file("~/.ssh/id_otus_ed25519.pub")}"
#    }
#  }

#v3
 provisioner "local-exec" {
    command = "sleep 60"
  }

 #Start Ansible

  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=${path.module}/../ansible/01_nginx/ansible.cfg ansible-playbook ${path.module}/../ansible/01_nginx/playbooks/01_nginx.yml ${path.module}/../ansible/01_nginx/playbooks/02_nftables_for_nginx.yml"
  }
}