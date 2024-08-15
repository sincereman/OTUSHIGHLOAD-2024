#!/bin/bash

echo "Check that you have a key without password (because ansible requre)  ssh-keygen -t ed25519  -f ~/.ssh/id_otus_ed25519 )"

vmname=otus-nginx-0
echo Create $vmname

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

cd tofu
tofu apply -auto-approve



echo "VM LAUNCHED"

#echo "Waiting https to launch on 443..."
#while ! nc -z $(yc compute instance get $vmname --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address') 443; do
#  sleep 5 # wait for 1 of the second before check again
#  echo "Wait https..."
#done
#echo "HTTPS launched"

#echo "Nginx was Provisioned"
echo Check link: https://$(yc compute instance get $vmname --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address')


read -p "Press key to continue to destroy VM " -n1 -s


tofu destroy -auto-approve




