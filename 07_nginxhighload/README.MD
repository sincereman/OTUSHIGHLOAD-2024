# Домашнее задание 07_higload

## Настройка конфигурации веб приложения под высокую нагрузку


## Цель: 
terraform (или vagrant) и ansible роль для развертывания серверов веб приложения под высокую нагрузку и отказоустойчивость
в работе должны применяться:

- keepalived, (в случае использовать vagrant и virtualbox), load balancer от yandex в случае использования яндекс клауд
- nginx,
- uwsgi/unicorn/php-fpm
- некластеризованная бд mysql/mongodb/postgres/redis


## Описание/Пошаговая инструкция выполнения домашнего задания:

    Создать несколько инстансов с помощью терраформ (2 nginx, 2 backend, 1 db);
    Развернуть nginx и keepalived на серверах nginx при помощи ansible
    Развернуть бэкенд способный работать по uwsgi/unicorn/php-fpm и базой. (Можно взять что нибудь из Django) при помощи ansible.
    Развернуть gfs2 для бэкенд серверах, для хранения статики
    Развернуть бд для работы бэкенда при помощи ansbile
    Проверить отказоустойчивость системы при выходе из строя серверов backend/nginx



## Выполнение

## Для проверки стенда потребуется.

Экспортировать переменные доступа к Yandex Cloud

```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```
из каталога tofu выполнить `tofu apply`

Склонировать к себе  домашнее задание git clone URL

В задании используется коллекция gluster.volume

!!! Обязательно выполнить  ansible-galaxy collection install -r requirements.yml  из каталога ansible, в противном случае не соберется glusterfs.


### Итоговый стенд приведен к виду

#### Сети:

``` shell

 yc-nlb (L7)  to frontend


frontend {
otus-frontend-1-web: 10.100.0.200 to nodeweb
otus-frontend-2-web: 10.100.0.201 to nodeweb
}

nodeweb {

otus-nodeweb-1-web: 10.100.0.10 / otus-nodeweb-1-db: 10.110.0.10 to nodedb
otus-nodeweb-2-web: 10.100.0.11 / otus-nodeweb-1-db: 10.110.0.11 to nodedb
otus-nodeweb-3-web: 10.100.0.12 / otus-nodeweb-1-db: 10.110.0.12 to nodedb
}

nodedb {
otus-nodedb-1-db: 10.110.0.50
}


```                               


Сделана подсеть для менеджмента через bastion host и две отдельных подсети для web трафика и для трафика баз данных
Добавлен еще один frontend и yc nlb балансировщик.


#### Стенд созданный opentofu

``` shell
Outputs:

lb_ip_address = [
    {
        external_address_spec = [
            {
                address    = "84.201.144.89"
                ip_version = "ipv4"
            },
        ]
        internal_address_spec = []
        name                  = "http"
        port                  = 80
        protocol              = "tcp"
        target_port           = 80
    },
]
otus-bastion = [
    {
        fqdn                    = "otus-bastion-1.ru-central1.internal"
        id                      = "epdpdvv1tk096tvke92v"
        internal_data_ip_manage = [
            "10.201.0.30",
        ]
        name                    = "otus-bastion-1"
        public_ip               = [
            "89.169.164.180",
        ]
    },
]
otus-frontend = [
    {
        fqdn                    = "otus-frontend-1.ru-central1.internal"
        id                      = "epdsprvemeo3l2hmndlk"
        internal_data_ip_manage = [
            "10.200.0.200",
        ]
        internal_data_ip_web    = [
            "10.100.0.200",
        ]
        name                    = "otus-frontend-1"
        public_ip               = [
            "89.169.161.107",
        ]
    },
    {
        fqdn                    = "otus-frontend-2.ru-central1.internal"
        id                      = "epdqcfugekgg9fs8gc3j"
        internal_data_ip_manage = [
            "10.200.0.201",
        ]
        internal_data_ip_web    = [
            "10.100.0.201",
        ]
        name                    = "otus-frontend-2"
        public_ip               = [
            "89.169.174.92",
        ]
    },
]
otus-nodedb = [
    {
        fqdn                    = "otus-nodedb-1.ru-central1.internal"
        id                      = "epdon38imdcesj4jeitm"
        internal_data_ip_db     = [
            "10.110.0.50",
        ]
        internal_data_ip_manage = [
            "10.200.0.50",
        ]
        name                    = "otus-nodedb-1"
    },
]
otus-nodeweb = [
    {
        fqdn                    = "otus-nodeweb-1.ru-central1.internal"
        id                      = "epddsivp6dc3010nlnvf"
        internal_data_ip_db     = [
            "10.110.0.10",
        ]
        internal_data_ip_manage = [
            "10.200.0.10",
        ]
        internal_data_ip_web    = [
            "10.100.0.10",
        ]
        name                    = "otus-nodeweb-1"
    },
    {
        fqdn                    = "otus-nodeweb-2.ru-central1.internal"
        id                      = "epdfpnjdgcm3h84663o7"
        internal_data_ip_db     = [
            "10.110.0.11",
        ]
        internal_data_ip_manage = [
            "10.200.0.11",
        ]
        internal_data_ip_web    = [
            "10.100.0.11",
        ]
        name                    = "otus-nodeweb-2"
    },
    {
        fqdn                    = "otus-nodeweb-3.ru-central1.internal"
        id                      = "epd8ghlec0mnje3gic4k"
        internal_data_ip_db     = [
            "10.110.0.12",
        ]
        internal_data_ip_manage = [
            "10.200.0.12",
        ]
        internal_data_ip_web    = [
            "10.100.0.12",
        ]
        name                    = "otus-nodeweb-3"
    },
]

```


### Дерево проекта

```shell
sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/07_nginxhighload$ tree
.
├── ansible
│   ├── ansible.cfg
│   ├── group_vars
│   │   └── all
│   │       └── main.yml
│   ├── inventories
│   │   └── hosts
│   ├── playbooks
│   │   ├── 000_start.yml
│   │   ├── 001_bastion.yml
│   │   ├── 002_base.yml
│   │   ├── 003_nginx_frontend.yml
│   │   ├── 004_backend_glusterfs.yml
│   │   ├── 005_nginx_backend.yml
│   │   ├── 006_install_database.yml
│   │   └── test.yml
│   ├── requirements.yml
│   ├── roles
│   │   ├── 001_bastion
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── 002_base
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── templates
│   │   │       └── hosts.j2
│   │   ├── 003_nginx_frontend
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   ├── templates
│   │   │   │   ├── app.conf.j2
│   │   │   │   └── nginx.conf.j2
│   │   │   └── vars
│   │   │       └── main.yml
│   │   ├── 004_backend_glusterfs
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   ├── templates
│   │   │   └── vars
│   │   │       └── main.yml
│   │   ├── 005_nginx_backend
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   ├── main.yml
│   │   │   │   ├── php-fpm.yml
│   │   │   │   └── wordpress.yml
│   │   │   ├── templates
│   │   │   │   ├── app.conf.j2
│   │   │   │   ├── index.html.j2
│   │   │   │   ├── index.php.j2
│   │   │   │   ├── nginx.conf.j2
│   │   │   │   └── wp-config.php.j2
│   │   │   └── vars
│   │   │       └── main.yml
│   │   └── 006_install_database
│   │       ├── handlers
│   │       │   └── main.yml
│   │       ├── tasks
│   │       │   └── main.yml
│   │       ├── templates
│   │       └── vars
│   │           └── main.yml
│   └── terraform.tfstate
├── images
├── opentofu.sh
├── README.MD
├── start.sh
└── tofu
    ├── ansible.tf
    ├── cloud-init.yml
    ├── images.tf
    ├── log.txt
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
    ├── vm-frontend.tf
    ├── vm-nlb.tf
    ├── vm-nodedb.tf
    └── vm-nodeweb.tf

37 directories, 62 files
```

Весь проект разделен на пять частей

- 000_start - запуск всех плейбуков
- 001_bastion - настройка хоста bastion - задел на будущее - в данной работе используется готовый nat instane
- 002_base - базовые пакеты chronyd сетевая аналитика
- 003_nginx-frontend - базовая настройка nginx для апстрим  - используется round-robin
- 004_backend_glusterfs - создание кластеризованой реплицируемой fs на базе glusterfs - несколько отошел от ДЗ - не хотелось повторять ДЗ 2
- 005_nginx_backend - относительно предыдущего ДЗ схлопнул в одну роль установку wordpress (можно и не ставить WP управляется переменной в var)
- 005_install_database - настройка mysql mariadb




#### Листинг работы opentofu и ansible

<details>

```shell


  
  ```
</details>



Итогом запуска станет настроенный wordpress на интерфейсе nlb балансировщика.

![alt text](<images/Screenshot from 2024-09-09 09-50-43.png>)

![alt text](<images/Screenshot from 2024-09-09 09-54-59.png>)

![alt text](<images/Screenshot from 2024-09-09 09-57-50.png>)

Выключим otus-frontend-1 и otus-nodeweb-3  - для эмуляции сбоя.

![alt text](<images/Screenshot from 2024-09-09 10-00-39.png>)

![alt text](<images/Screenshot from 2024-09-09 10-01-02.png>)

![alt text](<images/Screenshot from 2024-09-09 10-01-40.png>)

![alt text](<images/Screenshot from 2024-09-09 10-01-55.png>)

```shell


devops@otus-nodeweb-1:~$ sudo gluster volume status
Status of volume: g0
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick otus-nodeweb-1:/glusterfs/br0         59488     0          Y       8658 
Brick otus-nodeweb-2:/glusterfs/br0         55874     0          Y       8539 
Self-heal Daemon on localhost               N/A       N/A        Y       8675 
Self-heal Daemon on otus-nodeweb-2          N/A       N/A        Y       8556 
 
Task Status of Volume g0
------------------------------------------------------------------------------
There are no active volume tasks

root@otus-nodeweb-1:/home/devops# gluster pool list
UUID					Hostname      	State
ffee1f4e-0137-4eef-bc3d-b2587b4be14e	otus-nodeweb-2	Connected 
15353339-66ba-4c40-b99d-dc8fd3c58554	otus-nodeweb-3	Disconnected 
b41e7c9a-f425-4683-bb0d-e8538b2a7b14	localhost     	Connected 


root@otus-nodeweb-1:/home/devops# gluster volume heal g0 info
Brick otus-nodeweb-1:/glusterfs/br0
/test 
/ 
Status: Connected
Number of entries: 2

Brick otus-nodeweb-2:/glusterfs/br0
/test 
/ 
Status: Connected
Number of entries: 2

Brick otus-nodeweb-3:/glusterfs/br0
Status: Transport endpoint is not connected
Number of entries: -


```

```shell

devops@otus-frontend-2:~$ sudo tail -f /var/log/nginx/error.log 

2024/09/09 10:01:40 [error] 4121#4121: *25373 upstream timed out (110: Connection timed out) while connecting to upstream, client: 80.250.211.147, server: 89.169.174.53, request: "POST /wp-admin/admin-ajax.php HTTP/1.1", upstream: "http://10.100.0.12:80/wp-admin/admin-ajax.php", host: "84.201.151.65", referrer: "http://84.201.151.65/wp-admin/"



```

После отработки сбоя, узел бы исключен из пула, после запуска узла связность и целостность восстановилась, glusterfs volume также восстановился.


```shell

root@otus-nodeweb-1:/home/devops# gluster volume heal g0 info
Brick otus-nodeweb-1:/glusterfs/br0/g0
/test 
/ 
Status: Connected
Number of entries: 2

Brick otus-nodeweb-2:/glusterfs/br0/g0
/test 
/ 
Status: Connected
Number of entries: 2

Brick otus-nodeweb-3:/glusterfs/br0/g0
Status: Transport endpoint is not connected
Number of entries: -

root@otus-nodeweb-1:/home/devops# gluster volume heal g0 info
Brick otus-nodeweb-1:/glusterfs/br0/g0
Status: Connected
Number of entries: 0

Brick otus-nodeweb-2:/glusterfs/br0/g0
Status: Connected
Number of entries: 0

Brick otus-nodeweb-3:/glusterfs/br0/g0
Status: Connected
Number of entries: 0



```


## Задание выполнено!




