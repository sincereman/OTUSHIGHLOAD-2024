# Домашнее задание
## Настраиваем балансировку веб-приложения

### Цель: научиться использовать Nginx в качестве балансировщика


### Описание/Пошаговая инструкция выполнения домашнего задания:
В результате получаем рабочий пример Nginx в качестве балансировщика, и базовую отказоустойчивость бекенда.

Развернуть 4 виртуалки терраформом в яндекс облаке
- 1 виртуалка - Nginx - с публичным IP адресом- 
- 2 виртуалки - бэкенд на выбор студента ( любое приложение из гитхаба - uwsgi/unicorn/php-fpm/java) + nginx со статикой
- 1 виртуалкой с БД на выбор mysql/mongodb/postgres/redis.

В работе должны применяться:
terraform
ansible
nginx;
uwsgi/unicorn/php-fpm;
некластеризованная бд mysql/mongodb/postgres/redis.-

### Критерии оценки:

Преподаватель с помощью terraform apply должен получить развернутый стенд.


## Выполнение

## Для проверки стенда потребуется.

Экспортировать переменные доступа к Yandex Cloud

```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```
из каталога tofu выполнить `tofu apply`


### Итоговый стенд приведен к виду

#### Сети:
iscsi:

- iscsi1 - 10.200.0.0/24
- iscsi2 - 10.201.0.0/24

#### cluster:
data - 10.100.0.0/24




Один таргет - два адреса для iscsi и один менеджмент

Три ноды - два адреса для iscsi и один менеджмент

Настроен MPIO

#### Стенд созданный opentofu

``` shell

otus-bastion = [
  {
    "fqdn" = "otus-bastion-1.ru-central1.internal"
    "id" = "epdr6hk41l08ed6l9sup"
    "internal_data_ip_manage" = [
      "10.201.0.33",
    ]
    "name" = "otus-bastion-1"
    "public_ip" = [
      "51.250.103.154",
    ]
  },
]
otus-frontend = [
  {
    "fqdn" = "otus-frontend-1.ru-central1.internal"
    "id" = "epd6e49kvu5m0i4usfng"
    "internal_data_ip_manage" = [
      "10.200.0.200",
    ]
    "internal_data_ip_web" = [
      "10.100.0.200",
    ]
    "name" = "otus-frontend-1"
    "public_ip" = [
      "84.252.141.26",
    ]
  },
]
otus-nodedb = [
  {
    "fqdn" = "otus-nodedb-1.ru-central1.internal"
    "id" = "epdaoejbu2nf8nad1uct"
    "internal_data_ip_db" = [
      "10.110.0.50",
    ]
    "internal_data_ip_manage" = [
      "10.200.0.50",
    ]
    "name" = "otus-nodedb-1"
  },
]
otus-nodeweb = [
  {
    "fqdn" = "otus-nodeweb-1.ru-central1.internal"
    "id" = "epd28q40naavqmaismkl"
    "internal_data_ip_db" = [
      "10.110.0.10",
    ]
    "internal_data_ip_manage" = [
      "10.200.0.10",
    ]
    "internal_data_ip_web" = [
      "10.100.0.10",
    ]
    "name" = "otus-nodeweb-1"
  },
  {
    "fqdn" = "otus-nodeweb-2.ru-central1.internal"
    "id" = "epd116s5h5ogdmcfqhbr"
    "internal_data_ip_db" = [
      "10.110.0.11",
    ]
    "internal_data_ip_manage" = [
      "10.200.0.11",
    ]
    "internal_data_ip_web" = [
      "10.100.0.11",
    ]
    "name" = "otus-nodeweb-2"
  },
]
```


### Дерево проекта

```shell

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/06_nginxbalance$ tree
.
├── ansible
│   ├── ansible.cfg
│   ├── group_vars
│   │   └── all
│   │       └── main.yml
│   ├── inventories
│   ├── playbooks
│   │   ├── 000_start.yml
│   │   ├── 001_bastion.yml
│   │   ├── 002_base.yml
│   │   ├── 003_nginx_frontend.yml
│   │   ├── 004_nginx_backend.yml
│   │   ├── 005_install_database.yml
│   │   └── 006_nginx_backend_wordpress.yml
│   └── roles
│       ├── 001_bastion
│       │   ├── handlers
│       │   │   └── main.yml
│       │   └── tasks
│       │       └── main.yml
│       ├── 002_base
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   └── main.yml
│       │   └── templates
│       │       └── hosts.j2
│       ├── 003_nginx_frontend
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   └── main.yml
│       │   ├── templates
│       │   │   ├── app.conf.j2
│       │   │   └── nginx.conf.j2
│       │   └── vars
│       │       └── main.yml
│       ├── 004_nginx_backend
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   ├── main.yml
│       │   │   └── php-fpm.yml
│       │   ├── templates
│       │   │   ├── app.conf.j2
│       │   │   ├── index.html.j2
│       │   │   ├── index.php.j2
│       │   │   └── nginx.conf.j2
│       │   └── vars
│       │       └── main.yml
│       ├── 005_install_database
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   └── main.yml
│       │   ├── templates
│       │   └── vars
│       │       └── main.yml
│       └── 006_nginx_backend_wordpress
│           ├── handlers
│           │   └── main.yml
│           ├── tasks
│           │   └── main.yml
│           ├── templates
│           │   └── wp-config.php.j2
│           └── vars
│               └── main.yml
├── images
├── opentofu.sh
├── README.MD
├── start.sh
└── tofu
    ├── ansible.tf
    ├── cloud-init.yml
    ├── images.tf
    ├── net.tf
    ├── outputs.tf
    ├── providers.tf
    ├── route-table.tf
    ├── scripts
    │   └── waitssh.sh
    ├── security-group.tf
    ├── templates
    │   ├── group_vars_all.tpl
    │   └── inventory.tpl
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    ├── variables.tf
    ├── vm-bastion.tf
    ├── vm-front.tf
    ├── vm-nodedb.tf
    └── vm-nodeweb.tf


```

 И являет собой классический пример хорошего ansible и классического bashsible.

Разделен на пять частей

- 00_all - установка chronyd и наполнение /etc/hosts нодами
- 01_iscsi - создание iscsi таргета и подключение нод к таргету (использована коллекция ниже)

```shell

  sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/05_1_iscsi_gfs2_pacemaker/ansible$ cat requirements.yml 
  ---
  - src: ondrejhome.targetcli
  - src: ondrejhome.targetcli-modules
  - src: OndrejHome.iscsiadm

```

  `ansible-galaxy install -r requirements.yml`

- 02_mpio_configure - настроен multipath
- 03_pacemaker - установка pacemaker и создание кластера hacluster с паролем password
- 04_iscsifensing - реализация fencing на основе доступа ноды к iscsi таргету. При недоступности - нода отправляется в рестарт сервисом watchdog
- 05_gfs2_cluster - создание кластерного ресурса shared_fs


#### Листинг работы opentofu и ansible

<details>

```shell
sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/06_nginxbalance/tofu$ tofu apply
data.yandex_compute_image.debian12: Reading...
data.yandex_compute_image.centos8: Reading...
data.yandex_compute_image.centos9: Reading...
data.yandex_compute_image.nat-instance-ubuntu: Reading...
data.yandex_compute_image.centos8: Read complete after 0s [id=fd8qfp90a5l0m3d2htrm]
data.yandex_compute_image.nat-instance-ubuntu: Read complete after 0s [id=fd8kd604tsdb7egpnm98]
data.yandex_compute_image.debian12: Read complete after 0s [id=fd8do7rb69jm50c3u8bs]
data.yandex_compute_image.centos9: Read complete after 0s [id=fd8cj4jlm40vrrq4pc37]

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

OpenTofu will perform the following actions:

  # local_file.group_vars will be created
  + resource "local_file" "group_vars" {
      + content              = <<-EOT
            ---
            # group vars
            
            ip_address:
            otus-frontend-1-web: 10.100.0.200 
            otus-nodeweb-1-web: 10.100.0.10
            otus-nodeweb-1-db: 10.110.0.10 
            otus-nodeweb-2-web: 10.100.0.11
            otus-nodeweb-2-db: 10.110.0.11 
            otus-nodedb-1-db: 10.110.0.50
        EOT
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0644"
      + filename             = "./../ansible/group_vars/all/main.yml"
      + id                   = (known after apply)
    }

  # local_file.inventory will be created
  + resource "local_file" "inventory" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0644"
      + filename             = "./../ansible/inventories/hosts"
      + id                   = (known after apply)
    }

  # yandex_compute_instance.bastion[0] will be created
  + resource "yandex_compute_instance" "bastion" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "otus-bastion-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "enable-oslogin"     = "false"
          + "serial-port-enable" = "1"
          + "ssh-keys"           = <<-EOT
                devops:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
            EOT
          + "user-data"          = <<-EOT
                #cloud-config
                users:
                  - name: devops
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL'] 
                    ssh-authorized-keys:
                      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
                disable_root: true
                timezone: Europe/Moscow
                repo_update: true
                repo_upgrade: true
            EOT
        }
      + name                      = "otus-bastion-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8kd604tsdb7egpnm98"
              + name        = "boot-disk-bastion-1"
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = 0
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.frontend[0] will be created
  + resource "yandex_compute_instance" "frontend" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "otus-frontend-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "enable-oslogin"     = "false"
          + "serial-port-enable" = "1"
          + "ssh-keys"           = <<-EOT
                devops:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
            EOT
          + "user-data"          = <<-EOT
                #cloud-config
                users:
                  - name: devops
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL'] 
                    ssh-authorized-keys:
                      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
                disable_root: true
                timezone: Europe/Moscow
                repo_update: true
                repo_upgrade: true
            EOT
        }
      + name                      = "otus-frontend-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8do7rb69jm50c3u8bs"
              + name        = "boot-disk-frontend-1"
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = 0
          + ip_address         = "10.100.0.200"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = 1
          + ip_address         = "10.200.0.200"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.nodedb[0] will be created
  + resource "yandex_compute_instance" "nodedb" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "otus-nodedb-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
                devops:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
            EOT
          + "user-data" = <<-EOT
                #cloud-config
                users:
                  - name: devops
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL'] 
                    ssh-authorized-keys:
                      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
                disable_root: true
                timezone: Europe/Moscow
                repo_update: true
                repo_upgrade: true
            EOT
        }
      + name                      = "otus-nodedb-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8do7rb69jm50c3u8bs"
              + name        = "boot-disk-nodedb1"
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = 0
          + ip_address         = "10.200.0.50"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = 1
          + ip_address         = "10.110.0.50"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.nodeweb[0] will be created
  + resource "yandex_compute_instance" "nodeweb" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "otus-nodeweb-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
                devops:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
            EOT
          + "user-data" = <<-EOT
                #cloud-config
                users:
                  - name: devops
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL'] 
                    ssh-authorized-keys:
                      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
                disable_root: true
                timezone: Europe/Moscow
                repo_update: true
                repo_upgrade: true
            EOT
        }
      + name                      = "otus-nodeweb-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8do7rb69jm50c3u8bs"
              + name        = "boot-disk-nodeweb-1"
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = 0
          + ip_address         = "10.200.0.10"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = 1
          + ip_address         = "10.100.0.10"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = 2
          + ip_address         = "10.110.0.10"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.nodeweb[1] will be created
  + resource "yandex_compute_instance" "nodeweb" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "otus-nodeweb-2"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
                devops:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
            EOT
          + "user-data" = <<-EOT
                #cloud-config
                users:
                  - name: devops
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL'] 
                    ssh-authorized-keys:
                      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
                disable_root: true
                timezone: Europe/Moscow
                repo_update: true
                repo_upgrade: true
            EOT
        }
      + name                      = "otus-nodeweb-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8do7rb69jm50c3u8bs"
              + name        = "boot-disk-nodeweb-2"
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = 0
          + ip_address         = "10.200.0.11"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = 1
          + ip_address         = "10.100.0.11"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = 2
          + ip_address         = "10.110.0.11"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.data will be created
  + resource "yandex_vpc_network" "data" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "data-net"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_route_table.bastion-route will be created
  + resource "yandex_vpc_route_table" "bastion-route" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + labels     = (known after apply)
      + name       = "bastion-route"
      + network_id = (known after apply)

      + static_route {
          + destination_prefix = "0.0.0.0/0"
          + next_hop_address   = (known after apply)
        }
    }

  # yandex_vpc_security_group.nat-instance-sg will be created
  + resource "yandex_vpc_security_group" "nat-instance-sg" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + labels     = (known after apply)
      + name       = "sg_nat_name"
      + network_id = (known after apply)
      + status     = (known after apply)

      + egress {
          + description    = "any"
          + from_port      = -1
          + id             = (known after apply)
          + labels         = (known after apply)
          + port           = -1
          + protocol       = "ANY"
          + to_port        = -1
          + v4_cidr_blocks = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks = []
        }

      + ingress {
          + description    = "ext-http"
          + from_port      = -1
          + id             = (known after apply)
          + labels         = (known after apply)
          + port           = 80
          + protocol       = "TCP"
          + to_port        = -1
          + v4_cidr_blocks = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks = []
        }
      + ingress {
          + description    = "ext-https"
          + from_port      = -1
          + id             = (known after apply)
          + labels         = (known after apply)
          + port           = 443
          + protocol       = "TCP"
          + to_port        = -1
          + v4_cidr_blocks = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks = []
        }
      + ingress {
          + description    = "icmp"
          + from_port      = -1
          + id             = (known after apply)
          + labels         = (known after apply)
          + port           = -1
          + protocol       = "ICMP"
          + to_port        = -1
          + v4_cidr_blocks = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks = []
        }
      + ingress {
          + description    = "ssh"
          + from_port      = -1
          + id             = (known after apply)
          + labels         = (known after apply)
          + port           = 22
          + protocol       = "TCP"
          + to_port        = -1
          + v4_cidr_blocks = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks = []
        }
    }

  # yandex_vpc_subnet.subnet-db will be created
  + resource "yandex_vpc_subnet" "subnet-db" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnetdb"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.110.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.subnet-internet will be created
  + resource "yandex_vpc_subnet" "subnet-internet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnetinternet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.201.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.subnet-manage will be created
  + resource "yandex_vpc_subnet" "subnet-manage" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnetmanage"
      + network_id     = (known after apply)
      + route_table_id = (known after apply)
      + v4_cidr_blocks = [
          + "10.200.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.subnet-web will be created
  + resource "yandex_vpc_subnet" "subnet-web" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnetweb"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.100.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

Plan: 14 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + otus-bastion  = [
      + {
          + fqdn                    = (known after apply)
          + id                      = (known after apply)
          + internal_data_ip_manage = [
              + (known after apply),
            ]
          + name                    = "otus-bastion-1"
          + public_ip               = [
              + (known after apply),
            ]
        },
    ]
  + otus-frontend = [
      + {
          + fqdn                    = (known after apply)
          + id                      = (known after apply)
          + internal_data_ip_manage = [
              + "10.200.0.200",
            ]
          + internal_data_ip_web    = [
              + "10.100.0.200",
            ]
          + name                    = "otus-frontend-1"
          + public_ip               = [
              + (known after apply),
            ]
        },
    ]
  + otus-nodedb   = [
      + {
          + fqdn                    = (known after apply)
          + id                      = (known after apply)
          + internal_data_ip_db     = [
              + "10.110.0.50",
            ]
          + internal_data_ip_manage = [
              + "10.200.0.50",
            ]
          + name                    = "otus-nodedb-1"
        },
    ]
  + otus-nodeweb  = [
      + {
          + fqdn                    = (known after apply)
          + id                      = (known after apply)
          + internal_data_ip_db     = [
              + "10.110.0.10",
            ]
          + internal_data_ip_manage = [
              + "10.200.0.10",
            ]
          + internal_data_ip_web    = [
              + "10.100.0.10",
            ]
          + name                    = "otus-nodeweb-1"
        },
      + {
          + fqdn                    = (known after apply)
          + id                      = (known after apply)
          + internal_data_ip_db     = [
              + "10.110.0.11",
            ]
          + internal_data_ip_manage = [
              + "10.200.0.11",
            ]
          + internal_data_ip_web    = [
              + "10.100.0.11",
            ]
          + name                    = "otus-nodeweb-2"
        },
    ]

Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.data: Creating...
yandex_vpc_network.data: Creation complete after 1s [id=enp3hvendh2en7hn43t1]
yandex_vpc_subnet.subnet-internet: Creating...
yandex_vpc_subnet.subnet-web: Creating...
yandex_vpc_subnet.subnet-db: Creating...
yandex_vpc_security_group.nat-instance-sg: Creating...
yandex_vpc_subnet.subnet-internet: Creation complete after 1s [id=e2lkto4k4cm4jn755mdh]
yandex_vpc_subnet.subnet-db: Creation complete after 1s [id=e2l6vasn6dmc30b28rua]
yandex_vpc_security_group.nat-instance-sg: Creation complete after 1s [id=enp9vv4m8u2hvfo636ok]
yandex_compute_instance.bastion[0]: Creating...
yandex_vpc_subnet.subnet-web: Creation complete after 2s [id=e2lcq7l5mdtrg8migsct]
yandex_compute_instance.bastion[0]: Still creating... [10s elapsed]
yandex_compute_instance.bastion[0]: Still creating... [20s elapsed]
yandex_compute_instance.bastion[0]: Still creating... [30s elapsed]
yandex_compute_instance.bastion[0]: Creation complete after 37s [id=epdr6hk41l08ed6l9sup]
yandex_vpc_route_table.bastion-route: Creating...
yandex_vpc_route_table.bastion-route: Creation complete after 1s [id=enpd02l7ti3i9f5fmkd4]
yandex_vpc_subnet.subnet-manage: Creating...
yandex_vpc_subnet.subnet-manage: Creation complete after 0s [id=e2lpkq303q3bd0h68k2i]
yandex_compute_instance.nodedb[0]: Creating...
yandex_compute_instance.frontend[0]: Creating...
yandex_compute_instance.nodeweb[0]: Creating...
yandex_compute_instance.nodeweb[1]: Creating...
yandex_compute_instance.nodedb[0]: Still creating... [10s elapsed]
yandex_compute_instance.frontend[0]: Still creating... [10s elapsed]
yandex_compute_instance.nodeweb[0]: Still creating... [10s elapsed]
yandex_compute_instance.nodeweb[1]: Still creating... [10s elapsed]
yandex_compute_instance.nodedb[0]: Still creating... [20s elapsed]
yandex_compute_instance.frontend[0]: Still creating... [20s elapsed]
yandex_compute_instance.nodeweb[0]: Still creating... [20s elapsed]
yandex_compute_instance.nodeweb[1]: Still creating... [20s elapsed]
yandex_compute_instance.nodedb[0]: Still creating... [30s elapsed]
yandex_compute_instance.frontend[0]: Still creating... [30s elapsed]
yandex_compute_instance.nodeweb[1]: Still creating... [30s elapsed]
yandex_compute_instance.nodeweb[0]: Still creating... [30s elapsed]
yandex_compute_instance.nodeweb[0]: Creation complete after 40s [id=epd28q40naavqmaismkl]
yandex_compute_instance.nodedb[0]: Still creating... [40s elapsed]
yandex_compute_instance.frontend[0]: Still creating... [40s elapsed]
yandex_compute_instance.nodeweb[1]: Still creating... [40s elapsed]
yandex_compute_instance.nodedb[0]: Creation complete after 41s [id=epdaoejbu2nf8nad1uct]
yandex_compute_instance.frontend[0]: Creation complete after 45s [id=epd6e49kvu5m0i4usfng]
yandex_compute_instance.nodeweb[1]: Still creating... [50s elapsed]
yandex_compute_instance.nodeweb[1]: Still creating... [1m0s elapsed]
yandex_compute_instance.nodeweb[1]: Creation complete after 1m8s [id=epd116s5h5ogdmcfqhbr]
local_file.group_vars: Creating...
local_file.inventory: Creating...
local_file.group_vars: Creation complete after 0s [id=99f72e9662c194475eb46d2e4b7c1496a3571c82]
local_file.inventory: Provisioning with 'local-exec'...
local_file.inventory (local-exec): Executing: ["/bin/sh" "-c" "sleep 120"]
local_file.inventory: Still creating... [10s elapsed]
local_file.inventory: Still creating... [20s elapsed]
local_file.inventory: Still creating... [30s elapsed]
local_file.inventory: Still creating... [40s elapsed]
local_file.inventory: Still creating... [50s elapsed]
local_file.inventory: Still creating... [1m0s elapsed]
local_file.inventory: Still creating... [1m10s elapsed]
local_file.inventory: Still creating... [1m20s elapsed]
local_file.inventory: Still creating... [1m30s elapsed]
local_file.inventory: Still creating... [1m40s elapsed]
local_file.inventory: Still creating... [1m50s elapsed]
local_file.inventory: Still creating... [2m0s elapsed]
local_file.inventory: Provisioning with 'local-exec'...
local_file.inventory (local-exec): Executing: ["/bin/sh" "-c" "ANSIBLE_CONFIG=./../ansible/ansible.cfg ansible-playbook ./../ansible/playbooks/000_start.yml"]

local_file.inventory (local-exec): PLAY [Playbook of 000_start] ***************************************************

local_file.inventory (local-exec): TASK [Gathering Facts] *********************************************************
local_file.inventory (local-exec): ok: [otus-frontend-1]
local_file.inventory (local-exec): ok: [otus-bastion-1]
local_file.inventory (local-exec): ok: [otus-nodeweb-2]
local_file.inventory (local-exec): ok: [otus-nodedb-1]
local_file.inventory (local-exec): ok: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [002_base : Set hostname] *************************************************
local_file.inventory (local-exec): ok: [otus-frontend-1]
local_file.inventory (local-exec): ok: [otus-bastion-1]
local_file.inventory (local-exec): ok: [otus-nodeweb-2]
local_file.inventory (local-exec): ok: [otus-nodeweb-1]
local_file.inventory (local-exec): ok: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [002_base : set timezone] *************************************************
local_file.inventory (local-exec): changed: [otus-frontend-1]
local_file.inventory (local-exec): changed: [otus-bastion-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [002_base : Update and upgrade apt packages] ******************************
local_file.inventory: Still creating... [2m10s elapsed]
local_file.inventory (local-exec): ok: [otus-bastion-1]
local_file.inventory: Still creating... [2m20s elapsed]
local_file.inventory (local-exec): changed: [otus-frontend-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory: Still creating... [2m30s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]
local_file.inventory: Still creating... [2m40s elapsed]
local_file.inventory (local-exec): changed: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [002_base : Synchronize datetime | Install chrony] ************************
local_file.inventory (local-exec): changed: [otus-frontend-1]
local_file.inventory: Still creating... [2m50s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-bastion-1]
local_file.inventory (local-exec): changed: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [002_base : Synchronize datetime | Turn on chronyd] ***********************
local_file.inventory (local-exec): ok: [otus-frontend-1]
local_file.inventory (local-exec): ok: [otus-bastion-1]
local_file.inventory (local-exec): ok: [otus-nodeweb-2]
local_file.inventory (local-exec): ok: [otus-nodedb-1]
local_file.inventory (local-exec): ok: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [002_base : install base tools] *******************************************
local_file.inventory: Still creating... [3m0s elapsed]
local_file.inventory: Still creating... [3m10s elapsed]
local_file.inventory: Still creating... [3m20s elapsed]
local_file.inventory (local-exec): changed: [otus-frontend-1]
local_file.inventory: Still creating... [3m30s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-bastion-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]
local_file.inventory (local-exec): changed: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [003_nginx_frontend : Check Base Packages] ********************************
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item={'package': 'openssl', 'state': 'present'})
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item={'package': 'openssl', 'state': 'present'})
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item={'package': 'openssl', 'state': 'present'})
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item={'package': 'openssl', 'state': 'present'})
local_file.inventory: Still creating... [3m40s elapsed]
local_file.inventory (local-exec): changed: [otus-frontend-1] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): ok: [otus-frontend-1] => (item={'package': 'openssl', 'state': 'present'})

local_file.inventory (local-exec): TASK [003_nginx_frontend : Create a user nginx with a home directory] **********
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-frontend-1]

local_file.inventory (local-exec): TASK [003_nginx_frontend : adding existing user 'nginxuser' to group sudo] *****
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-frontend-1]

local_file.inventory (local-exec): TASK [003_nginx_frontend : Remove DefaultSite (delete file)] *******************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-frontend-1]

local_file.inventory (local-exec): TASK [003_nginx_frontend : Delete content & directory] *************************
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): changed: [otus-frontend-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): changed: [otus-frontend-1] => (item=/etc/nginx/sites-enabled)

local_file.inventory (local-exec): TASK [003_nginx_frontend : Create conf directory] ******************************
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): changed: [otus-frontend-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): changed: [otus-frontend-1] => (item=/etc/nginx/sites-enabled)

local_file.inventory (local-exec): TASK [003_nginx_frontend : Create an app directory if it does not exist] *******
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory: Still creating... [3m50s elapsed]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-frontend-1]

local_file.inventory (local-exec): TASK [003_nginx_frontend : Copy Nginx site-configuration file.] ****************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-frontend-1]

local_file.inventory (local-exec): TASK [003_nginx_frontend : Copy Nginx site-configuration file.] ****************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-frontend-1]

local_file.inventory (local-exec): TASK [003_nginx_frontend : Check Nginx Sites File Symlink] *********************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-frontend-1]

local_file.inventory (local-exec): TASK [004_nginx_backend : Check Base Packages] *********************************
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item={'package': 'openssl', 'state': 'present'})
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item={'package': 'apache2-utils', 'state': 'present'})
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item={'package': 'openssl', 'state': 'present'})
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item={'package': 'apache2-utils', 'state': 'present'})
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item={'package': 'openssl', 'state': 'present'})
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item={'package': 'apache2-utils', 'state': 'present'})
local_file.inventory: Still creating... [4m0s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-2] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): changed: [otus-nodeweb-1] => (item={'package': 'nginx', 'state': 'latest'})
local_file.inventory (local-exec): ok: [otus-nodeweb-2] => (item={'package': 'openssl', 'state': 'present'})
local_file.inventory (local-exec): ok: [otus-nodeweb-1] => (item={'package': 'openssl', 'state': 'present'})
local_file.inventory (local-exec): changed: [otus-nodeweb-2] => (item={'package': 'apache2-utils', 'state': 'present'})
local_file.inventory (local-exec): changed: [otus-nodeweb-1] => (item={'package': 'apache2-utils', 'state': 'present'})

local_file.inventory (local-exec): TASK [004_nginx_backend : Create a user nginx with a home directory] ***********
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]

local_file.inventory (local-exec): TASK [004_nginx_backend : adding existing user 'nginxuser' to group sudo] ******
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory: Still creating... [4m10s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [004_nginx_backend : Remove DefaultSite (delete file)] ********************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [004_nginx_backend : Delete content & directory] **************************
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled)

local_file.inventory (local-exec): TASK [004_nginx_backend : Create conf directory] *******************************
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-available)
local_file.inventory (local-exec): changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled)
local_file.inventory (local-exec): changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled)

local_file.inventory (local-exec): TASK [004_nginx_backend : Create an app directory if it does not exist] ********
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]

local_file.inventory (local-exec): TASK [004_nginx_backend : Copy Nginx index file.] ******************************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [004_nginx_backend : Copy Nginx site-configuration file.] *****************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [004_nginx_backend : Copy Nginx site-configuration file.] *****************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory: Still creating... [4m20s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [004_nginx_backend : Check Nginx Sites File Symlink] **********************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [004_nginx_backend : Include php-fpm service] *****************************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): included: /home/sincere/otus/02_highload/lessons/06_nginxbalance/ansible/roles/004_nginx_backend/tasks/php-fpm.yml for otus-nodeweb-1, otus-nodeweb-2

local_file.inventory (local-exec): TASK [004_nginx_backend : Copy Nginx index PHP file.] **************************
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [004_nginx_backend : Install PHP-FPM Debian] ******************************
local_file.inventory: Still creating... [4m30s elapsed]
local_file.inventory: Still creating... [4m40s elapsed]
local_file.inventory: Still creating... [4m50s elapsed]
local_file.inventory: Still creating... [5m0s elapsed]
local_file.inventory: Still creating... [5m10s elapsed]
local_file.inventory: Still creating... [5m20s elapsed]
local_file.inventory: Still creating... [5m30s elapsed]
local_file.inventory: Still creating... [5m40s elapsed]
local_file.inventory: Still creating... [5m50s elapsed]
local_file.inventory: Still creating... [6m0s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [004_nginx_backend : Start php-fpm service] *******************************
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [005_install_database : Installing mariadb-server] ************************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory: Still creating... [6m10s elapsed]
local_file.inventory: Still creating... [6m20s elapsed]
local_file.inventory: Still creating... [6m30s elapsed]
local_file.inventory (local-exec): changed: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [005_install_database : Start MariaDB] ************************************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): ok: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [005_install_database : Installing dependencies] **************************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory: Still creating... [6m40s elapsed]
local_file.inventory (local-exec): changed: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [005_install_database : Enable bind] **************************************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [005_install_database : Set the root password] ****************************
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=51.250.103.154)
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=10.110.0.50)
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=127.0.0.1)
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item=84.252.141.26)
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=::1)
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item=10.110.0.50)
local_file.inventory (local-exec): skipping: [otus-bastion-1] => (item=localhost)
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item=127.0.0.1)
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item=::1)
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item=10.200.0.10)
local_file.inventory (local-exec): skipping: [otus-frontend-1] => (item=localhost)
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item=10.110.0.50)
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item=127.0.0.1)
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item=::1)
local_file.inventory (local-exec): skipping: [otus-nodeweb-1] => (item=localhost)
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item=10.200.0.11)
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item=10.110.0.50)
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item=127.0.0.1)
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item=::1)
local_file.inventory (local-exec): skipping: [otus-nodeweb-2] => (item=localhost)
local_file.inventory: Still creating... [6m50s elapsed]
local_file.inventory (local-exec): changed: [otus-nodedb-1] => (item=10.200.0.50)
local_file.inventory (local-exec): changed: [otus-nodedb-1] => (item=10.110.0.50)
local_file.inventory (local-exec): changed: [otus-nodedb-1] => (item=127.0.0.1)
local_file.inventory (local-exec): changed: [otus-nodedb-1] => (item=::1)
local_file.inventory (local-exec): changed: [otus-nodedb-1] => (item=localhost)
local_file.inventory (local-exec): [WARNING]: Option column_case_sensitive is not provided. The default is now
local_file.inventory (local-exec): false, so the column's name will be uppercased. The default will be changed to
local_file.inventory (local-exec): true in community.mysql 4.0.0.

local_file.inventory (local-exec): TASK [005_install_database : Create mysql database] ****************************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [005_install_database : Create database user with name mysqluser and password from vars with all database privileges] ***
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : Wordpress | Remove elements from /var/www/html/] ***
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-1]
local_file.inventory (local-exec): skipping: [otus-nodeweb-2]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : Wordpress | Create directory] **************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : Wordpress | Extract archive in /usr/share/nginx/html/51.250.103.154] ***
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory: Still creating... [7m0s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : Wordpress | Move files from /usr/share/nginx/html/51.250.103.154/wordpress to /usr/share/nginx/html/51.250.103.154] ***
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : Wordpress | Remove wordpress dir] **********
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : Wordpress | Fetch random salts for wp-config.php] ***
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): ok: [otus-nodeweb-1]
local_file.inventory (local-exec): ok: [otus-nodeweb-2]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : set wp_salt fact] **************************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): ok: [otus-nodeweb-1]
local_file.inventory (local-exec): ok: [otus-nodeweb-2]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : Wordpress | Copy wp-config.php file] *******
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory: Still creating... [7m10s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : Wordpress | Change ownership of installation directory] ***
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): TASK [006_nginx_backend_wordpress : Installing dependencies] *******************
local_file.inventory (local-exec): skipping: [otus-bastion-1]
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory (local-exec): skipping: [otus-nodedb-1]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): RUNNING HANDLER [005_install_database : restart mariadb] ***********************
local_file.inventory (local-exec): changed: [otus-nodedb-1]

local_file.inventory (local-exec): RUNNING HANDLER [006_nginx_backend_wordpress : restart nginx] ******************
local_file.inventory (local-exec): skipping: [otus-frontend-1]
local_file.inventory: Still creating... [7m20s elapsed]
local_file.inventory (local-exec): changed: [otus-nodeweb-2]
local_file.inventory (local-exec): changed: [otus-nodeweb-1]

local_file.inventory (local-exec): PLAY RECAP *********************************************************************
local_file.inventory (local-exec): otus-bastion-1             : ok=7    changed=3    unreachable=0    failed=0    skipped=39   rescued=0    ignored=0
local_file.inventory (local-exec): otus-frontend-1            : ok=17   changed=14   unreachable=0    failed=0    skipped=30   rescued=0    ignored=0
local_file.inventory (local-exec): otus-nodedb-1              : ok=15   changed=11   unreachable=0    failed=0    skipped=32   rescued=0    ignored=0
local_file.inventory (local-exec): otus-nodeweb-1             : ok=32   changed=26   unreachable=0    failed=0    skipped=18   rescued=0    ignored=0
local_file.inventory (local-exec): otus-nodeweb-2             : ok=32   changed=26   unreachable=0    failed=0    skipped=18   rescued=0    ignored=0

local_file.inventory: Creation complete after 7m21s [id=2f5e57cfd7e8afec41ca1f8fa9c4d31696112320]

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

Outputs:

otus-bastion = [
  {
    "fqdn" = "otus-bastion-1.ru-central1.internal"
    "id" = "epdr6hk41l08ed6l9sup"
    "internal_data_ip_manage" = [
      "10.201.0.33",
    ]
    "name" = "otus-bastion-1"
    "public_ip" = [
      "51.250.103.154",
    ]
  },
]
otus-frontend = [
  {
    "fqdn" = "otus-frontend-1.ru-central1.internal"
    "id" = "epd6e49kvu5m0i4usfng"
    "internal_data_ip_manage" = [
      "10.200.0.200",
    ]
    "internal_data_ip_web" = [
      "10.100.0.200",
    ]
    "name" = "otus-frontend-1"
    "public_ip" = [
      "84.252.141.26",
    ]
  },
]
otus-nodedb = [
  {
    "fqdn" = "otus-nodedb-1.ru-central1.internal"
    "id" = "epdaoejbu2nf8nad1uct"
    "internal_data_ip_db" = [
      "10.110.0.50",
    ]
    "internal_data_ip_manage" = [
      "10.200.0.50",
    ]
    "name" = "otus-nodedb-1"
  },
]
otus-nodeweb = [
  {
    "fqdn" = "otus-nodeweb-1.ru-central1.internal"
    "id" = "epd28q40naavqmaismkl"
    "internal_data_ip_db" = [
      "10.110.0.10",
    ]
    "internal_data_ip_manage" = [
      "10.200.0.10",
    ]
    "internal_data_ip_web" = [
      "10.100.0.10",
    ]
    "name" = "otus-nodeweb-1"
  },
  {
    "fqdn" = "otus-nodeweb-2.ru-central1.internal"
    "id" = "epd116s5h5ogdmcfqhbr"
    "internal_data_ip_db" = [
      "10.110.0.11",
    ]
    "internal_data_ip_manage" = [
      "10.200.0.11",
    ]
    "internal_data_ip_web" = [
      "10.100.0.11",
    ]
    "name" = "otus-nodeweb-2"
  },
]

  
  ```
</details>

Готовый кластер на любой из нод

https://otus-node-x:2224

Логин: hacluster
Пароль: password

В каталоге images несколько скринов кластера


![главная](images/overview_2024-08-29_22-56-07.png)

![ноды](images/nodes_2024-08-29_22-57-38.png)

![ресурсы](./images/resources_2024-08-29_22-58-11.png)

![фенсинг](images/iscsi_shooter_2024-08-29_22-58-44.png)


## Задание выполнено!




