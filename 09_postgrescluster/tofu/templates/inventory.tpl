[bastions]
%{ for index, name in bastion_name ~}
${name} ansible_host=${bastion_external_ip_address[index]} ansible_ssh_user=devops ansible_ssh_private_key_file=~/.ssh/id_otus_ed25519 ansible_ssh_port=22 ansible_ssh_transfer_method=smart
%{ endfor ~}

[frontend]
%{ for index, name in frontend_name ~}
#${name} ansible_host=${frontend_internal_ip_address[index]}
${name} ansible_host=${frontend_external_ip_address[index]} ansible_ssh_user=devops ansible_ssh_private_key_file=~/.ssh/id_otus_ed25519 ansible_ssh_port=22 ansible_ssh_transfer_method=smart
%{ endfor ~}


[nodesweb]
%{ for index, name in nodeweb_name ~}
${name} ansible_host=${nodeweb_internal_ip_address[index]}
%{ endfor ~}

[nodesdb]
%{ for index, name in nodedb_name ~}
${name} ansible_host=${nodedb_internal_ip_address[index]}
%{ endfor ~}

[nodeshaproxybackend]
%{ for index, name in nodehaproxybackend_name ~}
${name} ansible_host=${nodehaproxybackend_internal_ip_address[index]}
%{ endfor ~}


[nodesetcdbackend]
%{ for index, name in nodeetcdbackend_name ~}
${name} ansible_host=${nodeetcdbackend_internal_ip_address[index]}
%{ endfor ~}



%{ for index, name in bastion_name ~}
[frontend:vars]
#ansible_ssh_user=devops 
#ansible_ssh_private_key_file=~/.ssh/id_otus_ed25519
#ansible_ssh_transfer_method=smart
#ansible_ssh_port=22
#ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q devops@${bastion_external_ip_address[index]} "'

[nodesweb:vars]
ansible_ssh_user=devops 
ansible_ssh_private_key_file=~/.ssh/id_otus_ed25519
ansible_ssh_transfer_method=smart
ansible_ssh_port=22
ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q devops@${bastion_external_ip_address[index]} "'

[nodesdb:vars]
ansible_ssh_user=devops 
ansible_ssh_private_key_file=~/.ssh/id_otus_ed25519
ansible_ssh_transfer_method=smart
ansible_ssh_port=22
ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q devops@${bastion_external_ip_address[index]} "'
%{ endfor ~}