[nginx]
%{ for index, name in nginx_name ~}
${name} ansible_host=${nginx_external_ip_address[index]} ansible_ssh_user=devops ansible_ssh_private_key_file=~/.ssh/id_otus_ed25519 ansible_ssh_port=22 ansible_ssh_transfer_method=smart
%{ endfor ~}