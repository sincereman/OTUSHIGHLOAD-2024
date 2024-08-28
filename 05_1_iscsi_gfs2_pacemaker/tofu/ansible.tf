# Generate inventory file for Ansible
resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventories/hosts"
  file_permission  = "0644"

  content = templatefile("${path.module}/templates/inventory.tpl", {
      iscsitarget_name               = yandex_compute_instance.iscsitarget.*.name,
      iscsitarget_external_ip_address = yandex_compute_instance.iscsitarget.*.network_interface.0.nat_ip_address,
      iscsitarget_internal_ip_address = yandex_compute_instance.iscsitarget.*.network_interface.0.ip_address,

      node_name               = yandex_compute_instance.node.*.name,
      node_external_ip_address = yandex_compute_instance.node.*.network_interface.0.nat_ip_address,
      node_internal_ip_address = yandex_compute_instance.node.*.network_interface.0.ip_address,
      
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
    command = "sleep 120"
  }

#Start Ansible

 provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=${path.module}/../ansible/ansible.cfg ansible-playbook ${path.module}/../ansible/playbooks/000_start.yml"
  }
}