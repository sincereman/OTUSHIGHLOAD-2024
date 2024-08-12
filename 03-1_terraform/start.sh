#!/bin/bash

echo "Check that you have a key without password (because ansible requre)  ssh-keygen -t ed25519  -f ~/.ssh/id_otus_ed25519 )"


if [ ! -f ~/.ssh/id_otus_ed25519.pub ]; then
    echo "Нет нужного ключа! Ansible не заработает! Создайте ключ БЕЗ пароля - >> ssh-keygen -t ed25519  -f ~/.ssh/id_otus_ed25519"
    exit 0
fi

OTUS_USER_PUB_KEY=$(cat ~/.ssh/id_otus_ed25519.pub)


cat > tofu/metayc.yml << EOM

#cloud-config
users:
  - name: devops
    groups: sudo
    shell: /bin/bash
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    ssh-authorized-keys:
    - $OTUS_USER_PUB_KEY
disable_root: true
timezone: Europe/Moscow
repo_update: true
repo_upgrade: true


EOM

export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)

cd tofu
tofu apply -auto-approve
cd ..


echo "VM LAUNCHED"
echo ip: $(yc compute instance get otus-l03-tf1 --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address') 

echo otus-l03-tf1 ansible_ssh_host=$(yc compute instance get otus-l03-tf1 --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address') > $PWD/ansible/01_nginx/inventories/hosts



echo "Waiting SSH to launch on 22..."
while ! nc -z $(yc compute instance get otus-l03-tf1 --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address') 22; do
  sleep 5 # wait for 1 of the second before check again
  echo "Wait SSH..."
done
echo "SSH launched"


echo Start Ansible Provisioning 
cd ansible/01_nginx
ansible-playbook playbooks/01_Nginx.yml playbooks/02_nftables_for_Nginx.yml


echo "Nginx Launched"
echo Check link: https://$(yc compute instance get otus-l03-tf1 --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address')


read -p "Press key to continue to destroy VM " -n1 -s

cd .. && cd ..

cd tofu
tofu destroy -auto-approve




