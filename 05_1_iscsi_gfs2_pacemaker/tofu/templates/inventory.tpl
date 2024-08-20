[iscsitargets]
%{ for index, name in iscsitarget_name ~}
${name} ansible_host=${iscsitarget_external_ip_address[index]} ansible_ssh_user=devops ansible_ssh_private_key_file=~/.ssh/id_otus_ed25519 ansible_ssh_port=22 ansible_ssh_transfer_method=smart
%{ endfor ~}

[nodes]
%{ for index, name in node_name ~}
${name} ansible_host=${node_external_ip_address[index]} ansible_ssh_user=devops ansible_ssh_private_key_file=~/.ssh/id_otus_ed25519 ansible_ssh_port=22 ansible_ssh_transfer_method=smart
%{ endfor ~}