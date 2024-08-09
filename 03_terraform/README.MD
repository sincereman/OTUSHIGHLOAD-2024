#Домашнее задание

##Создать Terraform скрипт

###Цель: Реализовать первый терраформ скрипт.

##Описание/Пошаговая инструкция выполнения домашнего задания:

Необходимо:

1. Реализовать терраформ для разворачивания одной виртуалки в yandex-cloud

2. Запровиженить nginx с помощью ansible

### Формат сдачи

1. Репозиторий с терраформ манифестами

Критерии оценки:

Преподаватель с помощью terraform apply должен получить развернутый стенд.


## Выполнение.

Подготовка стенда

1. Установка OpenTofu на Ubuntu 20.04

https://opentofu.org/docs/intro/install/


### По  инструкции создадим opentofu.sh


```bash

#!/bin/bash

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

#Set up the OpenTofu repository

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null
curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null
sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg

#Now you have to create the OpenTofu source list.


echo \
  "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | \
  sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null
sudo chmod a+r /etc/apt/sources.list.d/opentofu.list

#Installing OpenTofu

#Finally, you can install OpenTofu:

sudo apt-get update
sudo apt-get install -y tofu


```
### Предоставим права на выполнение и запустим 

```bash
chmod +x ./opentofu.sh
./opentofu.sh

### 
sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/03$ apt list tofu 
Listing... Done
tofu/any,now 1.8.1 amd64 [installed]
tofu/any 1.8.1 i386

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/03$ tofu -v
OpenTofu v1.8.1
on linux_amd64


```

2. Создадим подкаталог tofu (отделим от ansible)

```bash

mkdir tofu
cd tofu

```

По инструкции с  https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart создадим структуру проекта развертывания машины на Debian 12.


Предварительные шаги для создания учетных данных сервисного аккаунта

```bash

mkdir -p ~/otus/02_highload/lessons/00_account/01_yc #мини структура для хранения учеток

curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

cd ~/otus/02_highload/lessons/00_account/01_yc


echo 'source /home/sincere/yandex-cloud/completion.zsh.inc' >>  ~/.zshrc # try installer

# Перезапустить консоль

По инструкции https://yandex.cloud/ru/docs/cli/quickstart#yandex-account_1 - создадим конфиг для основного? пользователя

yc init

# Попросит Token - получить нужно https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb


You have one cloud available: 'cloud-safinanton' (id = b****************). It is going to be used by default.
Please choose folder to use:
 [1] 
 [2] otus (id = )
 [3] Create a new folder

 Please enter your numeric choice: 2
Your current folder has been set to 'otus' (id = b1gq4ctc08v06m78pd33).
Do you want to configure a default Compute zone? [Y/n] 
Which zone do you want to use as a profile default?
 [1] ru-central1-a
 [2] ru-central1-b
 [3] ru-central1-c
 [4] ru-central1-d
 [5] Don't set default zone
Please enter your numeric choice: 1
Your profile default Compute zone has been set to 'ru-central1-a'.

```

 Конфиг основного пользователя будет такой

```bash
sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/00_account/01_yc$ yc config list
token: y0_**********
cloud-id: b*****
folder-id: b***
compute-default-zone: ru-central1-a
```

Для devops лучше использовать сервисный аккаунт

данные берем в web части yc

yc iam key create \
  --service-account-id <идентификатор_сервисного_аккаунта> \
  --folder-name <имя_каталога_с_сервисным_аккаунтом> \
  --output key.json


```bash

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/00_account/01_yc$ yc iam key create \
>   --service-account-id aje4g*** \
>   --folder-name otus \
>   --output key.json
id: aje4g***
service_account_id: aje4g***
created_at: "2024-08-09T15:34:31.757664445Z"
key_algorithm: RSA_2048

#Создаем профиль

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/00_account/01_yc$ yc config profile create sa-opentofu
Profile 'sa-opentofu' created and activated


yc config set service-account-key key.json
yc config set cloud-id <идентификатор_облака>
yc config set folder-id <идентификатор_каталога>

# ID cloud / folder из части выше

# Добавим аутентификационные данные в переменные окружения:

export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)

```
Где:

YC_TOKEN — IAM-токен.
YC_CLOUD_ID — идентификатор облака.
YC_FOLDER_ID — идентификатор каталога.

Примечание

Время жизни IAM-токена — не больше 12 часов, но рекомендуется запрашивать его чаще, например каждый час.


То есть повторяем перед запуском tofu plan

Перейдем в наш каталог 

`cd ~/otus/02_highload/lessons/03/tofu/`

Из-за санкций поиск провайдера будеи искать в registry Яндекс Облака

nano ~/.terraformrc


Добавьте в него следующий блок:

```json

provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```


Создадим файл providers.tf

```shell
sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/03/tofu$ cat providers.tf 
terraform {

  required_providers {

    yandex = {

      source = "yandex-cloud/yandex"

    }

  }

  required_version = ">= 0.13"

}



provider "yandex" {

  zone = "<зона_доступности_по_умолчанию>"

}


Рузультат


```shell
sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/03/tofu$ tofu init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.126.0...
- Installed yandex-cloud/yandex v0.126.0. Signature validation was skipped due to the registry not containing GPG keys for this provider

OpenTofu has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that OpenTofu can guarantee to make the same selections by default when
you run "tofu init" in the future.

OpenTofu has been successfully initialized!

You may now begin working with OpenTofu. Try running "tofu plan" to see
any changes that are required for your infrastructure. All OpenTofu commands
should now work.

If you ever set or change modules or backend configuration for OpenTofu,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```


Начнем создавать vm.tf

Для его создания необходимо получить ID образа Debian-12

`yc compute image list --folder-id standard-images | grep -B 1 "debian-12"`

| fd801rku4j14mv7fs703 | debian-12-v20240506                                        | debian-12                                       | f2ensop16ipcgqe16qfg           | READY  |


и сгенерировать ssh ключик

`ssh-keygen -t ed25519  -f ~/.ssh/id_otus_ed2551`

Предитоговый файл vm.tf


```json

resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd8p9iv9fkpds5pueviu"
}

resource "yandex_compute_instance" "vm-1" {
  name = "otus-l03-tf1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_otus_ed25519.pub")}"
    user-data = "${file("metayc.txt")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}


output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}


```




И еще нюанс

Для добавления пользователей, как и для изменения многих других параметров ОС создаваемой виртуальной машины, в Yandex Cloud используется механизм cloud-init. Для этого необходимо передать текст конфигурации cloud-init в параметре user-data в блоке metadata. В нашем случае это будут системные пользователи:

Создайте текстовый файл с метаданными в кодировке UTF-8, например:

#cloud-config
users:
  - name: <имя_пользователя>
    groups: sudo
    shell: /bin/bash
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    ssh-authorized-keys:
      - <публичный_SSH-ключ_1>
      - <публичный_SSH-ключ_2>
      - ...
Где:

name — имя пользователя ВМ.

ssh-authorized-keys (также допустим вариант ssh_authorized_keys) — список публичных SSH-ключей для доступа к ВМ.

Пример ключа: ssh-ed25519 AAAAB3Nza...Pu00jRN user@desktop.

В файле main.tf вместо ssh-keys задайте параметр user-data и укажите путь к файлу с метаданными:

metadata = {
  user-data = "${file("<путь_к_файлу>/meta.txt")}"
}

Добавим сохраним и продолжим


```bash

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/03/tofu$ tree
.
├── metayc.txt
├── providers.tf
└── vm.tf

0 directories, 3 files
sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/03/tofu$ tofu validate
Success! The configuration is valid.
sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/03/tofu$ tofu plan

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

OpenTofu will perform the following actions:

  # yandex_compute_disk.boot-disk-1 will be created
  + resource "yandex_compute_disk" "boot-disk-1" {
      + block_size  = 4096
      + created_at  = (known after apply)
      + folder_id   = (known after apply)
      + id          = (known after apply)
      + image_id    = "fd87va5cc00gaq2f5qfb"
      + name        = "boot-disk-1"
      + product_ids = (known after apply)
      + size        = 20
      + status      = (known after apply)
      + type        = "network-hdd"
      + zone        = "ru-central1-a"
    }

  # yandex_compute_instance.vm-1 will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
                ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotus
            EOT
          + "user-data" = <<-EOT
                #cloud-config
                users:
                  - name: devops
                    groups: sudo
                    shell: /bin/bash
                    sudo: 'ALL=(ALL) NOPASSWD:ALL'
                    ssh-authorized-keys:
                      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmUhAyceqbbc3AivLkcg60EINDUgf8pTmvA0vnvs8gq sincere@sincere-ubuntuotu
            EOT
        }
      + name                      = "otus-l03-tf1"
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
        }

      + network_interface {
          + index              = (known after apply)
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
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }
    }

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network1"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet1"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_vm_1 = (known after apply)
  + internal_ip_address_vm_1 = (known after apply)

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so OpenTofu can't guarantee to take exactly these actions if you run
"tofu apply" now.
```

```shell

tofu apply


Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_vm_1 = (known after apply)
  + internal_ip_address_vm_1 = (known after apply)

Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_compute_instance.vm-1: Creating...
yandex_compute_instance.vm-1: Still creating... [10s elapsed]
yandex_compute_instance.vm-1: Still creating... [20s elapsed]
yandex_compute_instance.vm-1: Still creating... [30s elapsed]
yandex_compute_instance.vm-1: Creation complete after 32s [id=fhm06l8teroi22i85c4d]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_vm_1 = "51.250.70.171"
internal_ip_address_vm_1 = "192.168.10.28"

```

Магия случилась!)


Авторизуемся!

```shell

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/03/tofu$ ssh devops@51.250.70.171 -i ~/.ssh/id_otus_ed25519 
Linux fhm06l8teroi22i85c4d 6.1.0-11-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.38-4 (2023-08-08) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.

```


