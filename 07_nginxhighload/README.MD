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



                                  otus-nodeweb-1-web: 10.100.0.10
                                                otus-nodeweb-1-db: 10.110.0.10 
otus-frontend-1-web: 10.100.0.200                                                       otus-nodedb-1-db: 10.110.0.50 
                                                otus-nodeweb-2-db: 10.110.0.11 
                                  otus-nodeweb-2-web: 10.100.0.11

                                            


 Сделана подсеть для менеджмента через bastion host и две отдельных подсети для web трафика и для трафика баз данных

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

- 000_start - запуск всех gktq,erjd
- 001_bastion - настройка хоста bastion - задел на будущее - в данной работе используется готовый nat instane
- 002_base - базовые пакеты chronyd сетевая аналитика
- 003_nginx-frontend - базовая настройка nginx для апстрим rr
- 004_nginx_backend - базовая настройка бэкенда для rr  -  если выполнить плейбуки только 1,2,4,4 - то можно понаблюдать на публичном ip frontend что балансировка работает
- 005_install_database - настройка mysql mariadb
- 006_nginx_backend_wordpress - установка php-fpm и др. установка wordpress/




#### Листинг работы opentofu и ansible

<details>

```shell


  
  ```
</details>



Итогом запуска станет настроенный wordpress на публичном интерфейсе otus-frontend-1



Выключим otus-frontend-1 и otus-nodeweb-3  - для эмуляции сбоя.

Screenshot

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

После отработки сбоя, узел бы исключен из пула, после запуска узла связность и целостность восстановилась


```shell



```


В каталоге images несколько скринов

![alt text](<images/Screenshot from 2024-09-05 17-59-58.png>)



![alt text](<images/Screenshot from 2024-09-05 18-02-06.png>)
## Задание выполнено!




