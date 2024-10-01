# Домашнее задание 08_ mysql cluster (ProxySQL + Percona XtraDB Cluster)


ENDPOINTS=otus-backend-etcd-1:2379,otus-backend-etcd-2:2379,otus-backend-etcd-3:2379
etcdctl --endpoints=$ENDPOINTS endpoint health
etcdctl --write-out=table --endpoints=$ENDPOINTS endpoint status


По умолчанию, для ввода команд patronictl необходимо указывать путь до конфигурационного файла, например, мы вводили команду:

patronictl -c /etc/patroni/config.yml list

Чтобы этого не делать, мы можем указать путь до конфига с помощью системной переменной PATRONICTL_CONFIG_FILE:

export PATRONICTL_CONFIG_FILE=/etc/patroni/config.yml



Развернуть InnoDB или PXC кластер

## Цель:
Перевести базу веб-проекта на один из вариантов кластера MySQL: Percona XtraDB Cluster или InnoDB Cluster.

### Описание/Пошаговая инструкция выполнения домашнего задания:

    Разворачиваем отказоустойчивый кластер MySQL (Percona XtraDB Cluster или InnoDB Cluster) на ВМ или в докере любым способом.
    Создаем внутри кластера вашу БД для проекта. Если требуется тестовая БД, то можно загрузить дамп здесь: [https://dev.mysql.com/doc/index-other.html]
    Для упрощения запуска можно использовать репозитории с плейбуками Ansible для PXC (https://github.com/Nickmob/vagrant_percona_cluster) и InnoDB Cluster (https://github.com/Nickmob/vagrant_innodb_cluster). Код в репозиториях рассчитан на Debian-based дистрибутивы.
    В качестве результата пришлите ссылку на ваш git-репозиторий с кодом и результатами запуска кластера.


### Критерии оценки:

Статус "Принято" ставится при успешном запуске одного из вариантов кластера с базой данных.




## Выполнение

## Для проверки стенда потребуется.

Экспортировать переменные доступа к Yandex Cloud

```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```


Склонировать к себе  домашнее задание git clone URL

В задании используется коллекция gluster.volume

!!! Обязательно выполнить  ansible-galaxy collection install -r requirements.yml  из каталога ansible, в противном случае не соберется glusterfs.

из каталога tofu выполнить `tofu apply`



### Итоговый стенд приведен к виду

#### Сети:

``` shell

 yc-nlb (L7)  to frontend


frontend {
otus-frontend-1 10.100.0.200 to nodeweb
otus-frontend-2: 10.100.0.201 to nodeweb
}

nodeweb {

otus-nodeweb-1: 10.100.0.10 / otus-nodeweb-1-db: 10.110.0.10 to nodedb
otus-nodeweb-2: 10.100.0.11 / otus-nodeweb-1-db: 10.110.0.11 to nodedb
otus-nodeweb-3: 10.100.0.12 / otus-nodeweb-1-db: 10.110.0.12 to nodedb
}

nodedb {
otus-nodedb-1: 10.110.0.50
otus-nodedb-1: 10.110.0.51
otus-nodedb-1: 10.110.0.52
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
                address    = "51.250.42.190"
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
        id                      = "epd19me381o2q13ld9eg"
        internal_data_ip_manage = [
            "10.201.0.13",
        ]
        name                    = "otus-bastion-1"
        public_ip               = [
            "89.169.163.70",
        ]
    },
]
otus-frontend = [
    {
        fqdn                    = "otus-frontend-1.ru-central1.internal"
        id                      = "epdm2giej1qb8pkkj8o5"
        internal_data_ip_manage = [
            "10.200.0.200",
        ]
        internal_data_ip_web    = [
            "10.100.0.200",
        ]
        name                    = "otus-frontend-1"
        public_ip               = [
            "89.169.160.62",
        ]
    },
    {
        fqdn                    = "otus-frontend-2.ru-central1.internal"
        id                      = "epd9m0a9tnarr49g388e"
        internal_data_ip_manage = [
            "10.200.0.201",
        ]
        internal_data_ip_web    = [
            "10.100.0.201",
        ]
        name                    = "otus-frontend-2"
        public_ip               = [
            "89.169.161.130",
        ]
    },
]
otus-nodedb = [
    {
        fqdn                    = "otus-nodedb-1.ru-central1.internal"
        id                      = "epdlu8r7pdp5pp448sqr"
        internal_data_ip_db     = [
            "10.110.0.50",
        ]
        internal_data_ip_manage = [
            "10.200.0.50",
        ]
        name                    = "otus-nodedb-1"
    },
    {
        fqdn                    = "otus-nodedb-2.ru-central1.internal"
        id                      = "epd4a1skrv8ji681gogl"
        internal_data_ip_db     = [
            "10.110.0.51",
        ]
        internal_data_ip_manage = [
            "10.200.0.51",
        ]
        name                    = "otus-nodedb-2"
    },
    {
        fqdn                    = "otus-nodedb-3.ru-central1.internal"
        id                      = "epd8ia9hu3q78aqod194"
        internal_data_ip_db     = [
            "10.110.0.52",
        ]
        internal_data_ip_manage = [
            "10.200.0.52",
        ]
        name                    = "otus-nodedb-3"
    },
]
otus-nodeweb = [
    {
        fqdn                    = "otus-nodeweb-1.ru-central1.internal"
        id                      = "epdc2sg063s4r5qfnuvk"
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
        id                      = "epdg6115b282jgdj7kr0"
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
        id                      = "epd4205ifgs7to3buug2"
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

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/08_mysqlcluster$ tree
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
│   │   ├── 006_install_database_mysql.yml
│   │   ├── 007_install_proxysql.yml
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
│   │   │   │   └── nginx.conf.j2
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
│   │   ├── 006_install_database_mysql
│   │   │   ├── etc
│   │   │   │   ├── LICENSE
│   │   │   │   └── ssl
│   │   │   │       ├── ca.pem
│   │   │   │       ├── server-cert.pem
│   │   │   │       └── server-key.pem
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   ├── bootstrap_cluster.yml
│   │   │   │   ├── check-settings-centos.yml
│   │   │   │   ├── check-settings.yml
│   │   │   │   ├── configure-centos.yml
│   │   │   │   ├── configure.yml
│   │   │   │   ├── databases.yml
│   │   │   │   ├── install-centos.yml
│   │   │   │   ├── install.yml
│   │   │   │   ├── main.yml
│   │   │   │   ├── secure.yml
│   │   │   │   └── users.yml
│   │   │   ├── templates
│   │   │   │   ├── etc_my.cnf-centos.j2
│   │   │   │   ├── etc_mysql_my.cnf.j2
│   │   │   │   ├── etc_mysql_mysqld.cnf.j2
│   │   │   │   └── root-my-cnf.j2
│   │   │   └── vars
│   │   │       └── main.yml
│   │   └── 007_install_proxysql
│   │       ├── handlers
│   │       │   └── main.yml
│   │       ├── tasks
│   │       │   ├── check_vars.yml
│   │       │   ├── configure_proxysql.yml
│   │       │   ├── install_proxysql.yml
│   │       │   └── main.yml
│   │       ├── templates
│   │       │   ├── proxysql.cnf.j2
│   │       │   ├── proxysql.logrotate.conf.j2
│   │       │   └── proxysql.my.cnf.j2
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

44 directories, 90 files


```

Весь проект разделен на пять частей

- 000_start - запуск всех плейбуков
- 001_bastion - настройка хоста bastion - задел на будущее - в данной работе используется готовый nat instane
- 002_base - базовые пакеты chronyd сетевая аналитика
- 003_nginx-frontend - базовая настройка nginx для апстрим  - используется round-robin
- 004_backend_glusterfs - создание кластеризованой реплицируемой fs на базе glusterfs - несколько отошел от ДЗ - не хотелось повторять ДЗ 2
- 005_nginx_backend - относительно предыдущего ДЗ схлопнул в одну роль установку wordpress (можно и не ставить WP управляется переменной в var)
- 006_install_database_mysql - Установка и настройка Percona XtraDB Cluster, создание пользователей для ProxySQL, Wordpress и создание БД для wordpres. 
- 007_install_proxysql - установка ProxySQL - обратите внимание что ProxySQL ставится на nginx backend  -чтобы избежать необходимости установки еще одного промежуточного балансировщика. На мой взягляд отказоустойчивость обеспечена в этом случае в полном объеме.



#### Листинг работы opentofu и ansible

<details>

```shell

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/08_mysqlcluster/ansible$ ansible-playbook playbooks/000_start.yml 

PLAY [Playbook of 000_start] *******************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-frontend-1]
ok: [otus-frontend-2]
ok: [otus-bastion-1]
ok: [otus-nodeweb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]

TASK [002_base : Set hostname] *****************************************************************************************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-bastion-1]
ok: [otus-frontend-1]
ok: [otus-frontend-2]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]
ok: [otus-nodedb-3]

TASK [002_base : set timezone] *****************************************************************************************************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
changed: [otus-bastion-1]
changed: [otus-frontend-2]
changed: [otus-frontend-1]
changed: [otus-nodeweb-3]
changed: [otus-nodedb-1]
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]

TASK [002_base : Update and upgrade apt packages] **********************************************************************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-frontend-1]
ok: [otus-frontend-2]
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]
ok: [otus-bastion-1]

TASK [002_base : Synchronize datetime | Install chrony] ****************************************************************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-frontend-2]
ok: [otus-frontend-1]
ok: [otus-nodedb-3]
ok: [otus-bastion-1]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [002_base : Synchronize datetime | Turn on chronyd] ***************************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-frontend-1]
ok: [otus-bastion-1]
ok: [otus-frontend-2]
ok: [otus-nodeweb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]

TASK [002_base : install base tools] ***********************************************************************************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-frontend-1]
ok: [otus-frontend-2]
ok: [otus-bastion-1]
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [003_nginx_frontend : Check Base Packages] ************************************************************************************************************************************************************
skipping: [otus-bastion-1] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-bastion-1] => (item={'package': 'openssl', 'state': 'present'}) 
skipping: [otus-nodeweb-1] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-nodeweb-1] => (item={'package': 'openssl', 'state': 'present'}) 
skipping: [otus-nodeweb-2] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-nodeweb-2] => (item={'package': 'openssl', 'state': 'present'}) 
skipping: [otus-nodeweb-3] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-nodeweb-3] => (item={'package': 'openssl', 'state': 'present'}) 
skipping: [otus-nodedb-1] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-nodedb-1] => (item={'package': 'openssl', 'state': 'present'}) 
skipping: [otus-nodedb-2] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-nodedb-2] => (item={'package': 'openssl', 'state': 'present'}) 
skipping: [otus-nodedb-3] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-nodedb-3] => (item={'package': 'openssl', 'state': 'present'}) 
ok: [otus-frontend-1] => (item={'package': 'nginx', 'state': 'latest'})
ok: [otus-frontend-2] => (item={'package': 'nginx', 'state': 'latest'})
ok: [otus-frontend-1] => (item={'package': 'openssl', 'state': 'present'})
ok: [otus-frontend-2] => (item={'package': 'openssl', 'state': 'present'})

TASK [003_nginx_frontend : Create a user nginx with a home directory] **************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-frontend-1]
ok: [otus-frontend-2]

TASK [003_nginx_frontend : adding existing user 'nginxuser' to group sudo] *********************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-frontend-2]
ok: [otus-frontend-1]

TASK [003_nginx_frontend : Remove DefaultSite (delete file)] ***********************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-frontend-1]
ok: [otus-frontend-2]

TASK [003_nginx_frontend : Delete content & directory] *****************************************************************************************************************************************************
skipping: [otus-bastion-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-bastion-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodeweb-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodeweb-2] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodeweb-3] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodeweb-3] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-2] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-2] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-3] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-3] => (item=/etc/nginx/sites-enabled) 
changed: [otus-frontend-2] => (item=/etc/nginx/sites-available)
changed: [otus-frontend-1] => (item=/etc/nginx/sites-available)
changed: [otus-frontend-1] => (item=/etc/nginx/sites-enabled)
changed: [otus-frontend-2] => (item=/etc/nginx/sites-enabled)

TASK [003_nginx_frontend : Create conf directory] **********************************************************************************************************************************************************
skipping: [otus-bastion-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-bastion-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodeweb-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodeweb-2] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodeweb-3] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodeweb-3] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-2] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-2] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-3] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-3] => (item=/etc/nginx/sites-enabled) 
changed: [otus-frontend-1] => (item=/etc/nginx/sites-available)
changed: [otus-frontend-2] => (item=/etc/nginx/sites-available)
changed: [otus-frontend-2] => (item=/etc/nginx/sites-enabled)
changed: [otus-frontend-1] => (item=/etc/nginx/sites-enabled)

TASK [003_nginx_frontend : Create an app directory if it does not exist] ***********************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-frontend-1]
ok: [otus-frontend-2]

TASK [003_nginx_frontend : Copy Nginx site-configuration file.] ********************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-frontend-2]
ok: [otus-frontend-1]

TASK [003_nginx_frontend : Copy Nginx site-configuration file.] ********************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
changed: [otus-frontend-2]
changed: [otus-frontend-1]

TASK [003_nginx_frontend : Check Nginx Sites File Symlink] *************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
changed: [otus-frontend-2]
changed: [otus-frontend-1]

TASK [003_nginx_frontend : restart nginx] ******************************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
changed: [otus-frontend-1]
changed: [otus-frontend-2]

TASK [004_backend_glusterfs : Add node1 to /etc/hosts] *****************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [004_backend_glusterfs : Add node1 to /etc/hosts] *****************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]

TASK [004_backend_glusterfs : Add node1 to /etc/hosts] *****************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [004_backend_glusterfs : Install mkfs.xfs] ************************************************************************************************************************************************************
skipping: [otus-bastion-1] => (item={'package': 'xfsprogs', 'state': 'latest'}) 
skipping: [otus-frontend-1] => (item={'package': 'xfsprogs', 'state': 'latest'}) 
skipping: [otus-frontend-2] => (item={'package': 'xfsprogs', 'state': 'latest'}) 
skipping: [otus-nodedb-1] => (item={'package': 'xfsprogs', 'state': 'latest'}) 
skipping: [otus-nodedb-2] => (item={'package': 'xfsprogs', 'state': 'latest'}) 
skipping: [otus-nodedb-3] => (item={'package': 'xfsprogs', 'state': 'latest'}) 
ok: [otus-nodeweb-2] => (item={'package': 'xfsprogs', 'state': 'latest'})
ok: [otus-nodeweb-3] => (item={'package': 'xfsprogs', 'state': 'latest'})
ok: [otus-nodeweb-1] => (item={'package': 'xfsprogs', 'state': 'latest'})

TASK [004_backend_glusterfs : Configuring xfs on /dev/vdb] *************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]

TASK [004_backend_glusterfs : Ensure Gluster mount directories exist.] *************************************************************************************************************************************
skipping: [otus-bastion-1] => (item=/glusterfs) 
skipping: [otus-bastion-1] => (item=/glusterfs/br0) 
skipping: [otus-frontend-1] => (item=/glusterfs) 
skipping: [otus-frontend-1] => (item=/glusterfs/br0) 
skipping: [otus-frontend-2] => (item=/glusterfs) 
skipping: [otus-frontend-2] => (item=/glusterfs/br0) 
skipping: [otus-nodedb-1] => (item=/glusterfs) 
skipping: [otus-nodedb-1] => (item=/glusterfs/br0) 
skipping: [otus-nodedb-2] => (item=/glusterfs) 
skipping: [otus-nodedb-2] => (item=/glusterfs/br0) 
skipping: [otus-nodedb-3] => (item=/glusterfs) 
skipping: [otus-nodedb-3] => (item=/glusterfs/br0) 
ok: [otus-nodeweb-2] => (item=/glusterfs)
ok: [otus-nodeweb-1] => (item=/glusterfs)
ok: [otus-nodeweb-3] => (item=/glusterfs)
ok: [otus-nodeweb-2] => (item=/glusterfs/br0)
ok: [otus-nodeweb-1] => (item=/glusterfs/br0)
ok: [otus-nodeweb-3] => (item=/glusterfs/br0)

TASK [004_backend_glusterfs : Ensure Gluster disk is mounted.] *********************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [004_backend_glusterfs : Install GlusterFS server & client] *******************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-nodeweb-1]

TASK [004_backend_glusterfs : Restart GlusterFS] ***********************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [004_backend_glusterfs : Create a trusted storage pool] ***********************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-1]

TASK [004_backend_glusterfs : Ensure Gluster mount volume directories exist.] ******************************************************************************************************************************
skipping: [otus-bastion-1] => (item=/glusterfs/br0/g0) 
skipping: [otus-bastion-1] => (item=/opt/gfsvol) 
skipping: [otus-frontend-1] => (item=/glusterfs/br0/g0) 
skipping: [otus-frontend-1] => (item=/opt/gfsvol) 
skipping: [otus-frontend-2] => (item=/glusterfs/br0/g0) 
skipping: [otus-frontend-2] => (item=/opt/gfsvol) 
skipping: [otus-nodedb-1] => (item=/glusterfs/br0/g0) 
skipping: [otus-nodedb-1] => (item=/opt/gfsvol) 
skipping: [otus-nodedb-2] => (item=/glusterfs/br0/g0) 
skipping: [otus-nodedb-2] => (item=/opt/gfsvol) 
skipping: [otus-nodedb-3] => (item=/glusterfs/br0/g0) 
skipping: [otus-nodedb-3] => (item=/opt/gfsvol) 
ok: [otus-nodeweb-1] => (item=/glusterfs/br0/g0)
ok: [otus-nodeweb-2] => (item=/glusterfs/br0/g0)
ok: [otus-nodeweb-3] => (item=/glusterfs/br0/g0)
ok: [otus-nodeweb-1] => (item=/opt/gfsvol)
ok: [otus-nodeweb-2] => (item=/opt/gfsvol)
ok: [otus-nodeweb-3] => (item=/opt/gfsvol)

TASK [004_backend_glusterfs : Create gluster volume] *******************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-1]

TASK [004_backend_glusterfs : Start gluster volume] ********************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-1]

TASK [004_backend_glusterfs : Ensure Gluster volume is mounted.] *******************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]

TASK [005_nginx_backend : Check Base Packages] *************************************************************************************************************************************************************
skipping: [otus-bastion-1] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-frontend-1] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-frontend-2] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-nodedb-1] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-nodedb-2] => (item={'package': 'nginx', 'state': 'latest'}) 
skipping: [otus-nodedb-3] => (item={'package': 'nginx', 'state': 'latest'}) 
ok: [otus-nodeweb-2] => (item={'package': 'nginx', 'state': 'latest'})
ok: [otus-nodeweb-3] => (item={'package': 'nginx', 'state': 'latest'})
ok: [otus-nodeweb-1] => (item={'package': 'nginx', 'state': 'latest'})

TASK [005_nginx_backend : Create a user nginx with a home directory] ***************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]
ok: [otus-nodeweb-2]

TASK [005_nginx_backend : adding existing user 'nginxuser' to group sudo] **********************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [005_nginx_backend : Remove DefaultSite (delete file)] ************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [005_nginx_backend : Delete content & directory] ******************************************************************************************************************************************************
skipping: [otus-bastion-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-bastion-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-frontend-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-frontend-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-frontend-2] => (item=/etc/nginx/sites-available) 
skipping: [otus-frontend-2] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-2] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-2] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-3] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-3] => (item=/etc/nginx/sites-enabled) 
changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-3] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled)
changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled)
changed: [otus-nodeweb-3] => (item=/etc/nginx/sites-enabled)

TASK [005_nginx_backend : Create conf directory] ***********************************************************************************************************************************************************
skipping: [otus-bastion-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-bastion-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-frontend-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-frontend-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-frontend-2] => (item=/etc/nginx/sites-available) 
skipping: [otus-frontend-2] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-1] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-2] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-2] => (item=/etc/nginx/sites-enabled) 
skipping: [otus-nodedb-3] => (item=/etc/nginx/sites-available) 
skipping: [otus-nodedb-3] => (item=/etc/nginx/sites-enabled) 
changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-3] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled)
changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled)
changed: [otus-nodeweb-3] => (item=/etc/nginx/sites-enabled)

TASK [005_nginx_backend : Create an app directory if it does not exist] ************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
ok: [otus-nodeweb-3]

TASK [005_nginx_backend : Copy Nginx index file.] **********************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Copy Nginx site-configuration file.] *********************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [005_nginx_backend : Copy Nginx site-configuration file.] *********************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]

TASK [005_nginx_backend : Check Nginx Sites File Symlink] **************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]

TASK [005_nginx_backend : Include php-fpm service] *********************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/005_nginx_backend/tasks/php-fpm.yml for otus-nodeweb-1, otus-nodeweb-2, otus-nodeweb-3

TASK [005_nginx_backend : Copy Nginx index PHP file.] ******************************************************************************************************************************************************
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]

TASK [005_nginx_backend : Install PHP-FPM Debian] **********************************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [005_nginx_backend : Start php-fpm service] ***********************************************************************************************************************************************************
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Include wordpress section] *******************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/005_nginx_backend/tasks/wordpress.yml for otus-nodeweb-1, otus-nodeweb-2, otus-nodeweb-3

TASK [005_nginx_backend : Wordpress | Remove elements from /var/www/html/] *********************************************************************************************************************************
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]

TASK [005_nginx_backend : Wordpress | Create directory] ****************************************************************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Wordpress | Extract archive in /opt/gfsvol/wordpress] ****************************************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Wordpress | Move files from /opt/gfsvol/wordpress/wordpress to /opt/gfsvol/wordpress] ********************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Wordpress | Remove wordpress dir] ************************************************************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Wordpress | Fetch random salts for wp-config.php] ********************************************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
ok: [otus-nodeweb-1]

TASK [005_nginx_backend : set wp_salt fact] ****************************************************************************************************************************************************************
ok: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]

TASK [005_nginx_backend : Wordpress | Copy wp-config.php file] *********************************************************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Wordpress | Change ownership of installation directory] **************************************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
ok: [otus-nodeweb-1]

TASK [005_nginx_backend : Installing dependencies] *********************************************************************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]

TASK [006_install_database_mysql : Check settings] *********************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/006_install_database_mysql/tasks/check-settings.yml for otus-nodedb-1, otus-nodedb-2, otus-nodedb-3

TASK [006_install_database_mysql : Check if percona-server is installed] ***********************************************************************************************************************************
ok: [otus-nodedb-1]
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Check for innodb_log_file_size setting (Ubuntu)] ************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Abort when innodb_log_file_size changes] ********************************************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Check settings] *********************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Install packets (Debian)] ***********************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/006_install_database_mysql/tasks/install.yml for otus-nodedb-1, otus-nodedb-2, otus-nodedb-3

TASK [006_install_database_mysql : Install gnupg] **********************************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Install percona-release package] ****************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Update apt cache] *******************************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Configure Percona repo for PXC] *****************************************************************************************************************************************
changed: [otus-nodedb-3]
changed: [otus-nodedb-2]
changed: [otus-nodedb-1]

TASK [006_install_database_mysql : Configure Percona repo for tools] ***************************************************************************************************************************************
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]
changed: [otus-nodedb-2]

TASK [006_install_database_mysql : Update apt cache] *******************************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Install python-is-python3 (Ubuntu >= Focal/20.04)] **********************************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : ansible.builtin.debug] **************************************************************************************************************************************************
ok: [otus-nodedb-1] => {
    "msg": "ansible_python_interpreter major version: 3"
}
ok: [otus-nodedb-2] => {
    "msg": "ansible_python_interpreter major version: 3"
}
ok: [otus-nodedb-3] => {
    "msg": "ansible_python_interpreter major version: 3"
}

TASK [006_install_database_mysql : Install package dependencies for ansible MySQL modules (python 2)] ******************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Install package dependencies for ansible MySQL modules (python 3)] ******************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Install percona cluster packages, ProxySQL and dependencies on Debian] **************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Install mc, percona-toolkit and Percona Xtrabackup] *********************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Adjust permissions of datadir] ******************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Install packets (Red Hat)] **********************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Configure (Debian)] *****************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/006_install_database_mysql/tasks/configure.yml for otus-nodedb-1, otus-nodedb-2, otus-nodedb-3

TASK [006_install_database_mysql : Add node1 to /etc/hosts] ************************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Add node1 to /etc/hosts] ************************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Add node1 to /etc/hosts] ************************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Update the my.cnf] ******************************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Update the mysqld.cnf] **************************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-2]
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Restart mysql to apply changes done in my.cnf file] *********************************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Copy the same SSL certs to all nodes (./ssl dir from project)] **********************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Configure (Red Hat)] ****************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Bootstrap cluster] ******************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/006_install_database_mysql/tasks/bootstrap_cluster.yml for otus-nodedb-1, otus-nodedb-2, otus-nodedb-3

TASK [006_install_database_mysql : Start bootstap service] *************************************************************************************************************************************************
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
fatal: [otus-nodedb-1]: FAILED! => {"changed": false, "msg": "Unable to start service mysql@bootstrap: Job for mysql@bootstrap.service failed because the control process exited with error code.\nSee \"systemctl status mysql@bootstrap.service\" and \"journalctl -xeu mysql@bootstrap.service\" for details.\n"}
...ignoring

TASK [006_install_database_mysql : Pause 2 seconds to let bootstrap start] *********************************************************************************************************************************
Pausing for 2 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Start mysql services] ***************************************************************************************************************************************************
skipping: [otus-nodedb-1]
ok: [otus-nodedb-2]
ok: [otus-nodedb-3]

TASK [006_install_database_mysql : Pause 3 seconds to let hosts sync] **************************************************************************************************************************************
Pausing for 3 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Stop bootstrap] *********************************************************************************************************************************************************
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Start mysql service on first] *******************************************************************************************************************************************
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Secure installation] ****************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/006_install_database_mysql/tasks/secure.yml for otus-nodedb-1, otus-nodedb-2, otus-nodedb-3

TASK [006_install_database_mysql : Check if /root/.my.cnf file exists if installing >= 5.7 on Red Hat (to determine if new install)] ***********************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Parse temporary password from mysql log, getting last one] **************************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Set root password (using temp password to log in)] **********************************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Red Hat: Copy .my.cnf file into the root home folder after initial root password changed] *******************************************************************************
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Set the root password] **************************************************************************************************************************************************
ok: [otus-nodedb-3] => (item=otus-nodedb-3)
[WARNING]: Option column_case_sensitive is not provided. The default is now false, so the column's name will be uppercased. The default will be changed to true in community.mysql 4.0.0.
ok: [otus-nodedb-1] => (item=otus-nodedb-1)
ok: [otus-nodedb-2] => (item=otus-nodedb-2)

TASK [006_install_database_mysql : Copy .my.cnf file into the root home folder] ****************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Pause 2 seconds] ********************************************************************************************************************************************************
Pausing for 2 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Set the root password] **************************************************************************************************************************************************
changed: [otus-nodedb-3] => (item=127.0.0.1)
ok: [otus-nodedb-1] => (item=127.0.0.1)
ok: [otus-nodedb-2] => (item=127.0.0.1)
changed: [otus-nodedb-3] => (item=::1)
ok: [otus-nodedb-1] => (item=::1)
ok: [otus-nodedb-2] => (item=::1)
changed: [otus-nodedb-3] => (item=localhost)
ok: [otus-nodedb-2] => (item=localhost)
ok: [otus-nodedb-1] => (item=localhost)

TASK [006_install_database_mysql : Ensure anonymous users are not in the database] *************************************************************************************************************************
ok: [otus-nodedb-3] => (item=otus-nodedb-3)
ok: [otus-nodedb-2] => (item=otus-nodedb-2)
ok: [otus-nodedb-1] => (item=otus-nodedb-1)
ok: [otus-nodedb-3] => (item=localhost)
ok: [otus-nodedb-2] => (item=localhost)
ok: [otus-nodedb-1] => (item=localhost)

TASK [006_install_database_mysql : Remove the test database] ***********************************************************************************************************************************************
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]

TASK [006_install_database_mysql : Remove the wordpress database] ******************************************************************************************************************************************
ok: [otus-nodedb-1]

TASK [006_install_database_mysql : Setup DBs] **************************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/006_install_database_mysql/tasks/databases.yml for otus-nodedb-1, otus-nodedb-2, otus-nodedb-3

TASK [006_install_database_mysql : Make sure the MySQL databases are present] ******************************************************************************************************************************
changed: [otus-nodedb-3] => (item={'name': 'wordpress', 'collation': 'utf8_general_ci', 'encoding': 'utf8'})
ok: [otus-nodedb-1] => (item={'name': 'wordpress', 'collation': 'utf8_general_ci', 'encoding': 'utf8'})
ok: [otus-nodedb-2] => (item={'name': 'wordpress', 'collation': 'utf8_general_ci', 'encoding': 'utf8'})

TASK [006_install_database_mysql : Load timezone database into MySQL] **************************************************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [006_install_database_mysql : Create users] ***********************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/006_install_database_mysql/tasks/users.yml for otus-nodedb-1, otus-nodedb-2, otus-nodedb-3

TASK [006_install_database_mysql : Make sure the MySQL users are present] **********************************************************************************************************************************
changed: [otus-nodedb-3] => (item=None)
ok: [otus-nodedb-2] => (item=None)
ok: [otus-nodedb-1] => (item=None)
changed: [otus-nodedb-3] => (item=None)
changed: [otus-nodedb-3]
ok: [otus-nodedb-1] => (item=None)
ok: [otus-nodedb-1]
ok: [otus-nodedb-2] => (item=None)
ok: [otus-nodedb-2]

TASK [007_install_proxysql : check_vars] *******************************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [007_install_proxysql : install_proxysql] *************************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/007_install_proxysql/tasks/install_proxysql.yml for otus-nodeweb-1, otus-nodeweb-2, otus-nodeweb-3

TASK [007_install_proxysql : Install gnupg] ****************************************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-nodeweb-1]

TASK [007_install_proxysql : Adds repository key] **********************************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [007_install_proxysql : Adds percona repositories] ****************************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-nodeweb-1]

TASK [007_install_proxysql : Installs proxysql & python-mysqldb] *******************************************************************************************************************************************
ok: [otus-nodeweb-2] => (item=['proxysql', 'python3-mysqldb'])
ok: [otus-nodeweb-1] => (item=['proxysql', 'python3-mysqldb'])
ok: [otus-nodeweb-3] => (item=['proxysql', 'python3-mysqldb'])

TASK [007_install_proxysql : Holds proxysql version] *******************************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [007_install_proxysql : Installs mysql-common & client] ***********************************************************************************************************************************************
ok: [otus-nodeweb-2] => (item=['mysql-common', 'default-mysql-client'])
ok: [otus-nodeweb-1] => (item=['mysql-common', 'default-mysql-client'])
ok: [otus-nodeweb-3] => (item=['mysql-common', 'default-mysql-client'])

TASK [007_install_proxysql : configure_proxysql] ***********************************************************************************************************************************************************
skipping: [otus-bastion-1]
skipping: [otus-frontend-1]
skipping: [otus-frontend-2]
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
included: /home/sincere/otus/02_highload/lessons/08_mysqlcluster/ansible/roles/007_install_proxysql/tasks/configure_proxysql.yml for otus-nodeweb-1, otus-nodeweb-2, otus-nodeweb-3

TASK [007_install_proxysql : Configures proxysql] **********************************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [007_install_proxysql : Ensures proxysql is started and enabled] **************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [007_install_proxysql : Creates log dir] **************************************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]

TASK [007_install_proxysql : Adds logrotate] ***************************************************************************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]

TASK [007_install_proxysql : Adds proxysql.my.cnf] *********************************************************************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]
ok: [otus-nodeweb-2]

RUNNING HANDLER [005_nginx_backend : restart nginx] ********************************************************************************************************************************************************
skipping: [otus-frontend-2]
skipping: [otus-frontend-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]

RUNNING HANDLER [005_nginx_backend : reload nginx] *********************************************************************************************************************************************************
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]

PLAY RECAP *************************************************************************************************************************************************************************************************
otus-bastion-1             : ok=7    changed=1    unreachable=0    failed=0    skipped=51   rescued=0    ignored=0   
otus-frontend-1            : ok=18   changed=6    unreachable=0    failed=0    skipped=41   rescued=0    ignored=0   
otus-frontend-2            : ok=18   changed=6    unreachable=0    failed=0    skipped=41   rescued=0    ignored=0   
otus-nodedb-1              : ok=47   changed=3    unreachable=0    failed=0    skipped=54   rescued=0    ignored=1   
otus-nodedb-2              : ok=41   changed=3    unreachable=0    failed=0    skipped=56   rescued=0    ignored=0   
otus-nodedb-3              : ok=41   changed=6    unreachable=0    failed=0    skipped=56   rescued=0    ignored=0   
otus-nodeweb-1             : ok=60   changed=17   unreachable=0    failed=0    skipped=23   rescued=0    ignored=0   
otus-nodeweb-2             : ok=49   changed=12   unreachable=0    failed=0    skipped=34   rescued=0    ignored=0   
otus-nodeweb-3             : ok=49   changed=11   unreachable=0    failed=0    skipped=34   rescued=0    ignored=0  
  
```

</details>



Итогом запуска станет настроенный wordpress на интерфейсе nlb балансировщика.




```shell

devops@otus-nodedb-1:~$ sudo -s
root@otus-nodedb-1:/home/devops# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 485
Server version: 8.0.36-28.1 Percona XtraDB Cluster (GPL), Release rel28, Revision bfb687f, WSREP version 26.1.4.3

Copyright (c) 2009-2024 Percona LLC and/or its affiliates
Copyright (c) 2000, 2024, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show status like 'wsrep%';
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
| Variable_name                    | Value                                                                                                                                          |
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
| wsrep_local_state_uuid           | f6816bd1-72b7-11ef-9023-07a9b5465b3d                                                                                                           |
| wsrep_protocol_version           | 11                                                                                                                                             |
| wsrep_last_applied               | 277                                                                                                                                            |
| wsrep_last_committed             | 277                                                                                                                                            |
| wsrep_monitor_status (L/A/C)     | [ (277, 277), (277, 277), (277, 277) ]                                                                                                         |
| wsrep_replicated                 | 32                                                                                                                                             |
| wsrep_replicated_bytes           | 62696                                                                                                                                          |
| wsrep_repl_keys                  | 145                                                                                                                                            |
| wsrep_repl_keys_bytes            | 1928                                                                                                                                           |
| wsrep_repl_data_bytes            | 58613                                                                                                                                          |
| wsrep_repl_other_bytes           | 0                                                                                                                                              |
| wsrep_received                   | 244                                                                                                                                            |
| wsrep_received_bytes             | 3384808                                                                                                                                        |
| wsrep_local_commits              | 29                                                                                                                                             |
| wsrep_local_cert_failures        | 0                                                                                                                                              |
| wsrep_local_replays              | 0                                                                                                                                              |
| wsrep_local_send_queue           | 0                                                                                                                                              |
| wsrep_local_send_queue_max       | 2                                                                                                                                              |
| wsrep_local_send_queue_min       | 0                                                                                                                                              |
| wsrep_local_send_queue_avg       | 0.027027                                                                                                                                       |
| wsrep_local_recv_queue           | 0                                                                                                                                              |
| wsrep_local_recv_queue_max       | 40                                                                                                                                             |
| wsrep_local_recv_queue_min       | 0                                                                                                                                              |
| wsrep_local_recv_queue_avg       | 3.58197                                                                                                                                        |
| wsrep_local_cached_downto        | 1                                                                                                                                              |
| wsrep_flow_control_paused_ns     | 0                                                                                                                                              |
| wsrep_flow_control_paused        | 0                                                                                                                                              |
| wsrep_flow_control_sent          | 0                                                                                                                                              |
| wsrep_flow_control_recv          | 0                                                                                                                                              |
| wsrep_flow_control_active        | false                                                                                                                                          |
| wsrep_flow_control_requested     | false                                                                                                                                          |
| wsrep_flow_control_interval      | [ 173, 173 ]                                                                                                                                   |
| wsrep_flow_control_interval_low  | 173                                                                                                                                            |
| wsrep_flow_control_interval_high | 173                                                                                                                                            |
| wsrep_flow_control_status        | OFF                                                                                                                                            |
| wsrep_cert_deps_distance         | 1.00369                                                                                                                                        |
| wsrep_apply_oooe                 | 0                                                                                                                                              |
| wsrep_apply_oool                 | 0                                                                                                                                              |
| wsrep_apply_window               | 2.18315                                                                                                                                        |
| wsrep_apply_waits                | 80                                                                                                                                             |
| wsrep_commit_oooe                | 0                                                                                                                                              |
| wsrep_commit_oool                | 0                                                                                                                                              |
| wsrep_commit_window              | 1                                                                                                                                              |
| wsrep_local_state                | 4                                                                                                                                              |
| wsrep_local_state_comment        | Synced                                                                                                                                         |
| wsrep_cert_index_size            | 23                                                                                                                                             |
| wsrep_cert_bucket_count          | 257                                                                                                                                            |
| wsrep_gcache_pool_size           | 3457152                                                                                                                                        |
| wsrep_causal_reads               | 0                                                                                                                                              |
| wsrep_cert_interval              | 0.00369004                                                                                                                                     |
| wsrep_open_transactions          | 0                                                                                                                                              |
| wsrep_open_connections           | 0                                                                                                                                              |
| wsrep_ist_receive_status         |                                                                                                                                                |
| wsrep_ist_receive_seqno_start    | 0                                                                                                                                              |
| wsrep_ist_receive_seqno_current  | 0                                                                                                                                              |
| wsrep_ist_receive_seqno_end      | 0                                                                                                                                              |
| wsrep_incoming_addresses         | 10.110.0.51:3306,10.110.0.52:3306,10.110.0.50:3306                                                                                             |
| wsrep_cluster_weight             | 3                                                                                                                                              |
| wsrep_desync_count               | 0                                                                                                                                              |
| wsrep_evs_delayed                |                                                                                                                                                |
| wsrep_evs_evict_list             |                                                                                                                                                |
| wsrep_evs_repl_latency           | 0/0/0/0/0                                                                                                                                      |
| wsrep_evs_state                  | OPERATIONAL                                                                                                                                    |
| wsrep_gcomm_uuid                 | 42360ff4-72bc-11ef-8e78-1e8190ec2f7e                                                                                                           |
| wsrep_gmcast_segment             | 0                                                                                                                                              |
| wsrep_cluster_capabilities       |                                                                                                                                                |
| wsrep_cluster_conf_id            | 5                                                                                                                                              |
| wsrep_cluster_size               | 3                                                                                                                                              |
| wsrep_cluster_state_uuid         | f6816bd1-72b7-11ef-9023-07a9b5465b3d                                                                                                           |
| wsrep_cluster_status             | Primary                                                                                                                                        |
| wsrep_connected                  | ON                                                                                                                                             |
| wsrep_local_bf_aborts            | 0                                                                                                                                              |
| wsrep_local_index                | 2                                                                                                                                              |
| wsrep_provider_capabilities      | :MULTI_MASTER:CERTIFICATION:PARALLEL_APPLYING:TRX_REPLAY:ISOLATION:PAUSE:CAUSAL_READS:INCREMENTAL_WRITESET:UNORDERED:PREORDERED:STREAMING:NBO: |
| wsrep_provider_name              | Galera                                                                                                                                         |
| wsrep_provider_vendor            | Codership Oy <info@codership.com> (modified by Percona <https://percona.com/>)                                                                 |
| wsrep_provider_version           | 4.17(aa2461d)                                                                                                                                  |
| wsrep_ready                      | ON                                                                                                                                             |
| wsrep_thread_count               | 9                                                                                                                                              |
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
79 rows in set (0.02 sec)



mysql> SELECT SUBSTRING_INDEX(host, ':', 1) AS host_short, GROUP_CONCAT(DISTINCT user) AS users, COUNT(*) AS threads FROM information_schema.processlist GROUP BY host_short ORDER BY COUNT(*), host_short;
+-------------------------------------+-------------------------+---------+
| host_short                          | users                   | threads |
+-------------------------------------+-------------------------+---------+
| localhost                           | event_scheduler,root    |       2 |
| otus-nodeweb-2.ru-central1.internal | mysqluser,psmonitoruser |       2 |
| otus-nodeweb-1.ru-central1.internal | mysqluser,psmonitoruser |       3 |
| otus-nodeweb-3.ru-central1.internal | mysqluser,psmonitoruser |       3 |
|                                     | system user             |       9 |
+-------------------------------------+-------------------------+---------+
5 rows in set, 1 warning (0.00 sec)


```

Немного сломаем

```shell
root@otus-nodedb-3:/home/devops# systemctl stop mysql
root@otus-nodedb-3:/home/devops# systemctl status mysql
○ mysql.service - Percona XtraDB Cluster
     Loaded: loaded (/lib/systemd/system/mysql.service; enabled; preset: enabled)
     Active: inactive (dead) since Sat 2024-09-14 20:42:26 MSK; 6s ago
   Duration: 32min 10.151s
    Process: 16483 ExecStartPre=/usr/bin/mysql-systemd start-pre (code=exited, status=0/SUCCESS)
    Process: 16520 ExecStartPre=/usr/bin/mysql-systemd check-grastate (code=exited, status=0/SUCCESS)
    Process: 16549 ExecStartPre=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
    Process: 16551 ExecStartPre=/bin/sh -c VAR=`bash /usr/bin/mysql-systemd galera-recovery`; [ $? -eq 0 ] && systemctl set-environment _WSREP_START_POSITION=$VAR || exit 1 (code=exited, status=0/SUCCESS)
    Process: 16599 ExecStart=/usr/sbin/mysqld $_WSREP_START_POSITION (code=exited, status=0/SUCCESS)
    Process: 17466 ExecStartPost=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
    Process: 17468 ExecStartPost=/usr/bin/mysql-systemd start-post $MAINPID (code=exited, status=0/SUCCESS)
    Process: 22076 ExecStop=/usr/bin/mysql-systemd stop (code=exited, status=0/SUCCESS)
    Process: 22105 ExecStopPost=/usr/bin/mysql-systemd stop-post (code=exited, status=0/SUCCESS)
   Main PID: 16599 (code=exited, status=0/SUCCESS)
     Status: "Server shutdown complete"
        CPU: 50.193s

Sep 14 20:09:59 otus-nodedb-3 systemd[1]: mysql.service: Got notification message from PID 17334, but reception only permitted for main PID 16599
Sep 14 20:10:00 otus-nodedb-3 mysql-systemd[17468]:  SUCCESS!
Sep 14 20:10:00 otus-nodedb-3 systemd[1]: Started mysql.service - Percona XtraDB Cluster.
Sep 14 20:42:10 otus-nodedb-3 systemd[1]: Stopping mysql.service - Percona XtraDB Cluster...
Sep 14 20:42:11 otus-nodedb-3 mysql-systemd[22076]:  SUCCESS! Stopping Percona XtraDB Cluster......
Sep 14 20:42:26 otus-nodedb-3 mysql-systemd[22105]:  WARNING: mysql pid file /var/run/mysqld/mysqld.pid empty or not readable
Sep 14 20:42:26 otus-nodedb-3 mysql-systemd[22105]:  WARNING: mysql may be already dead
Sep 14 20:42:26 otus-nodedb-3 systemd[1]: mysql.service: Deactivated successfully.
Sep 14 20:42:26 otus-nodedb-3 systemd[1]: Stopped mysql.service - Percona XtraDB Cluster.
Sep 14 20:42:26 otus-nodedb-3 systemd[1]: mysql.service: Consumed 50.193s CPU time.

mysql> show status like 'wsrep%';
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
| Variable_name                    | Value                                                                                                                                          |
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
| wsrep_local_state_uuid           | f6816bd1-72b7-11ef-9023-07a9b5465b3d                                                                                                           |
| wsrep_protocol_version           | 11                                                                                                                                             |
| wsrep_last_applied               | 278                                                                                                                                            |
| wsrep_last_committed             | 278                                                                                                                                            |
| wsrep_monitor_status (L/A/C)     | [ (278, 278), (278, 278), (278, 278) ]                                                                                                         |
| wsrep_replicated                 | 32                                                                                                                                             |
| wsrep_replicated_bytes           | 62696                                                                                                                                          |
| wsrep_repl_keys                  | 145                                                                                                                                            |
| wsrep_repl_keys_bytes            | 1928                                                                                                                                           |
| wsrep_repl_data_bytes            | 58613                                                                                                                                          |
| wsrep_repl_other_bytes           | 0                                                                                                                                              |
| wsrep_received                   | 245                                                                                                                                            |
| wsrep_received_bytes             | 3385032                                                                                                                                        |
| wsrep_local_commits              | 29                                                                                                                                             |
| wsrep_local_cert_failures        | 0                                                                                                                                              |
| wsrep_local_replays              | 0                                                                                                                                              |
| wsrep_local_send_queue           | 0                                                                                                                                              |
| wsrep_local_send_queue_max       | 2                                                                                                                                              |
| wsrep_local_send_queue_min       | 0                                                                                                                                              |
| wsrep_local_send_queue_avg       | 0.027027                                                                                                                                       |
| wsrep_local_recv_queue           | 0                                                                                                                                              |
| wsrep_local_recv_queue_max       | 40                                                                                                                                             |
| wsrep_local_recv_queue_min       | 0                                                                                                                                              |
| wsrep_local_recv_queue_avg       | 3.56735                                                                                                                                        |
| wsrep_local_cached_downto        | 1                                                                                                                                              |
| wsrep_flow_control_paused_ns     | 0                                                                                                                                              |
| wsrep_flow_control_paused        | 0                                                                                                                                              |
| wsrep_flow_control_sent          | 0                                                                                                                                              |
| wsrep_flow_control_recv          | 0                                                                                                                                              |
| wsrep_flow_control_active        | false                                                                                                                                          |
| wsrep_flow_control_requested     | false                                                                                                                                          |
| wsrep_flow_control_interval      | [ 141, 141 ]                                                                                                                                   |
| wsrep_flow_control_interval_low  | 141                                                                                                                                            |
| wsrep_flow_control_interval_high | 141                                                                                                                                            |
| wsrep_flow_control_status        | OFF                                                                                                                                            |
| wsrep_cert_deps_distance         | 1.00369                                                                                                                                        |
| wsrep_apply_oooe                 | 0                                                                                                                                              |
| wsrep_apply_oool                 | 0                                                                                                                                              |
| wsrep_apply_window               | 2.18315                                                                                                                                        |
| wsrep_apply_waits                | 80                                                                                                                                             |
| wsrep_commit_oooe                | 0                                                                                                                                              |
| wsrep_commit_oool                | 0                                                                                                                                              |
| wsrep_commit_window              | 1                                                                                                                                              |
| wsrep_local_state                | 4                                                                                                                                              |
| wsrep_local_state_comment        | Synced                                                                                                                                         |
| wsrep_cert_index_size            | 23                                                                                                                                             |
| wsrep_cert_bucket_count          | 257                                                                                                                                            |
| wsrep_gcache_pool_size           | 3457400                                                                                                                                        |
| wsrep_causal_reads               | 0                                                                                                                                              |
| wsrep_cert_interval              | 0.00369004                                                                                                                                     |
| wsrep_open_transactions          | 0                                                                                                                                              |
| wsrep_open_connections           | 0                                                                                                                                              |
| wsrep_ist_receive_status         |                                                                                                                                                |
| wsrep_ist_receive_seqno_start    | 0                                                                                                                                              |
| wsrep_ist_receive_seqno_current  | 0                                                                                                                                              |
| wsrep_ist_receive_seqno_end      | 0                                                                                                                                              |
| wsrep_incoming_addresses         | 10.110.0.51:3306,10.110.0.50:3306                                                                                                              |
| wsrep_cluster_weight             | 2                                                                                                                                              |
| wsrep_desync_count               | 0                                                                                                                                              |
| wsrep_evs_delayed                |                                                                                                                                                |
| wsrep_evs_evict_list             |                                                                                                                                                |
| wsrep_evs_repl_latency           | 0/0/0/0/0                                                                                                                                      |
| wsrep_evs_state                  | OPERATIONAL                                                                                                                                    |
| wsrep_gcomm_uuid                 | 42360ff4-72bc-11ef-8e78-1e8190ec2f7e                                                                                                           |
| wsrep_gmcast_segment             | 0                                                                                                                                              |
| wsrep_cluster_capabilities       |                                                                                                                                                |
| wsrep_cluster_conf_id            | 6                                                                                                                                              |
| wsrep_cluster_size               | 2                                                                                                                                              |
| wsrep_cluster_state_uuid         | f6816bd1-72b7-11ef-9023-07a9b5465b3d                                                                                                           |
| wsrep_cluster_status             | Primary                                                                                                                                        |
| wsrep_connected                  | ON                                                                                                                                             |
| wsrep_local_bf_aborts            | 0                                                                                                                                              |
| wsrep_local_index                | 1                                                                                                                                              |
| wsrep_provider_capabilities      | :MULTI_MASTER:CERTIFICATION:PARALLEL_APPLYING:TRX_REPLAY:ISOLATION:PAUSE:CAUSAL_READS:INCREMENTAL_WRITESET:UNORDERED:PREORDERED:STREAMING:NBO: |
| wsrep_provider_name              | Galera                                                                                                                                         |
| wsrep_provider_vendor            | Codership Oy <info@codership.com> (modified by Percona <https://percona.com/>)                                                                 |
| wsrep_provider_version           | 4.17(aa2461d)                                                                                                                                  |
| wsrep_ready                      | ON                                                                                                                                             |
| wsrep_thread_count               | 9                                                                                                                                              |
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
79 rows in set (0.00 sec)


MySQL [(none)]> SELECT hostgroup_id,hostname,port,status FROM runtime_mysql_servers;
+--------------+-------------+------+---------+
| hostgroup_id | hostname    | port | status  |
+--------------+-------------+------+---------+
| 0            | 10.110.0.50 | 3306 | ONLINE  |
| 0            | 10.110.0.51 | 3306 | ONLINE  |
| 0            | 10.110.0.52 | 3306 | SHUNNED |
+--------------+-------------+------+---------+
3 rows in set (0.002 sec)



```
Обратно запустим mysql на otus-nodedb-3

```shell

root@otus-nodedb-3:/home/devops# systemctl start mysql
root@otus-nodedb-3:/home/devops# systemctl status mysql
● mysql.service - Percona XtraDB Cluster
     Loaded: loaded (/lib/systemd/system/mysql.service; enabled; preset: enabled)
     Active: active (running) since Sat 2024-09-14 20:44:54 MSK; 9s ago
    Process: 22140 ExecStartPre=/usr/bin/mysql-systemd start-pre (code=exited, status=0/SUCCESS)
    Process: 22177 ExecStartPre=/usr/bin/mysql-systemd check-grastate (code=exited, status=0/SUCCESS)
    Process: 22206 ExecStartPre=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
    Process: 22208 ExecStartPre=/bin/sh -c VAR=`bash /usr/bin/mysql-systemd galera-recovery`; [ $? -eq 0 ] && systemctl set-environment _WSREP_START_POSITION=$VAR || exit 1 (code=exited, status=0/SUCCESS)
    Process: 22882 ExecStartPost=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
    Process: 22884 ExecStartPost=/usr/bin/mysql-systemd start-post $MAINPID (code=exited, status=0/SUCCESS)
   Main PID: 22256 (mysqld)
     Status: "Server is operational"
      Tasks: 54 (limit: 2305)
     Memory: 413.7M
        CPU: 6.885s
     CGroup: /system.slice/mysql.service
             └─22256 /usr/sbin/mysqld --wsrep_start_position=f6816bd1-72b7-11ef-9023-07a9b5465b3d:277

Sep 14 20:44:47 otus-nodedb-3 systemd[1]: Starting mysql.service - Percona XtraDB Cluster...
Sep 14 20:44:51 otus-nodedb-3 systemd[1]: mysql.service: Got notification message from PID 22684, but reception only permitted for main PID 22256
Sep 14 20:44:54 otus-nodedb-3 mysql-systemd[22884]:  SUCCESS!
Sep 14 20:44:54 otus-nodedb-3 systemd[1]: Started mysql.service - Percona XtraDB Cluster.


```


После отработки сбоя mysql, узел бы исключен из пула, после запуска узла связность и целостность восстановилась.


```shell

mysql> show status like 'wsrep%';
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
| Variable_name                    | Value                                                                                                                                          |
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
| wsrep_local_state_uuid           | f6816bd1-72b7-11ef-9023-07a9b5465b3d                                                                                                           |
| wsrep_protocol_version           | 11                                                                                                                                             |
| wsrep_last_applied               | 279                                                                                                                                            |
| wsrep_last_committed             | 279                                                                                                                                            |
| wsrep_monitor_status (L/A/C)     | [ (279, 279), (279, 279), (279, 279) ]                                                                                                         |
| wsrep_replicated                 | 32                                                                                                                                             |
| wsrep_replicated_bytes           | 62696                                                                                                                                          |
| wsrep_repl_keys                  | 145                                                                                                                                            |
| wsrep_repl_keys_bytes            | 1928                                                                                                                                           |
| wsrep_repl_data_bytes            | 58613                                                                                                                                          |
| wsrep_repl_other_bytes           | 0                                                                                                                                              |
| wsrep_received                   | 246                                                                                                                                            |
| wsrep_received_bytes             | 3385336                                                                                                                                        |
| wsrep_local_commits              | 29                                                                                                                                             |
| wsrep_local_cert_failures        | 0                                                                                                                                              |
| wsrep_local_replays              | 0                                                                                                                                              |
| wsrep_local_send_queue           | 0                                                                                                                                              |
| wsrep_local_send_queue_max       | 2                                                                                                                                              |
| wsrep_local_send_queue_min       | 0                                                                                                                                              |
| wsrep_local_send_queue_avg       | 0.027027                                                                                                                                       |
| wsrep_local_recv_queue           | 0                                                                                                                                              |
| wsrep_local_recv_queue_max       | 40                                                                                                                                             |
| wsrep_local_recv_queue_min       | 0                                                                                                                                              |
| wsrep_local_recv_queue_avg       | 3.55285                                                                                                                                        |
| wsrep_local_cached_downto        | 1                                                                                                                                              |
| wsrep_flow_control_paused_ns     | 0                                                                                                                                              |
| wsrep_flow_control_paused        | 0                                                                                                                                              |
| wsrep_flow_control_sent          | 0                                                                                                                                              |
| wsrep_flow_control_recv          | 0                                                                                                                                              |
| wsrep_flow_control_active        | false                                                                                                                                          |
| wsrep_flow_control_requested     | false                                                                                                                                          |
| wsrep_flow_control_interval      | [ 173, 173 ]                                                                                                                                   |
| wsrep_flow_control_interval_low  | 173                                                                                                                                            |
| wsrep_flow_control_interval_high | 173                                                                                                                                            |
| wsrep_flow_control_status        | OFF                                                                                                                                            |
| wsrep_cert_deps_distance         | 1.00369                                                                                                                                        |
| wsrep_apply_oooe                 | 0                                                                                                                                              |
| wsrep_apply_oool                 | 0                                                                                                                                              |
| wsrep_apply_window               | 2.18315                                                                                                                                        |
| wsrep_apply_waits                | 80                                                                                                                                             |
| wsrep_commit_oooe                | 0                                                                                                                                              |
| wsrep_commit_oool                | 0                                                                                                                                              |
| wsrep_commit_window              | 1                                                                                                                                              |
| wsrep_local_state                | 4                                                                                                                                              |
| wsrep_local_state_comment        | Synced                                                                                                                                         |
| wsrep_cert_index_size            | 23                                                                                                                                             |
| wsrep_cert_bucket_count          | 257                                                                                                                                            |
| wsrep_gcache_pool_size           | 3457912                                                                                                                                        |
| wsrep_causal_reads               | 0                                                                                                                                              |
| wsrep_cert_interval              | 0.00369004                                                                                                                                     |
| wsrep_open_transactions          | 0                                                                                                                                              |
| wsrep_open_connections           | 0                                                                                                                                              |
| wsrep_ist_receive_status         |                                                                                                                                                |
| wsrep_ist_receive_seqno_start    | 0                                                                                                                                              |
| wsrep_ist_receive_seqno_current  | 0                                                                                                                                              |
| wsrep_ist_receive_seqno_end      | 0                                                                                                                                              |
| wsrep_incoming_addresses         | 10.110.0.52:3306,10.110.0.51:3306,10.110.0.50:3306                                                                                             |
| wsrep_cluster_weight             | 3                                                                                                                                              |
| wsrep_desync_count               | 0                                                                                                                                              |
| wsrep_evs_delayed                |                                                                                                                                                |
| wsrep_evs_evict_list             |                                                                                                                                                |
| wsrep_evs_repl_latency           | 0.00171546/0.502288/1.00286/0.500572/2                                                                                                         |
| wsrep_evs_state                  | OPERATIONAL                                                                                                                                    |
| wsrep_gcomm_uuid                 | 42360ff4-72bc-11ef-8e78-1e8190ec2f7e                                                                                                           |
| wsrep_gmcast_segment             | 0                                                                                                                                              |
| wsrep_cluster_capabilities       |                                                                                                                                                |
| wsrep_cluster_conf_id            | 7                                                                                                                                              |
| wsrep_cluster_size               | 3                                                                                                                                              |
| wsrep_cluster_state_uuid         | f6816bd1-72b7-11ef-9023-07a9b5465b3d                                                                                                           |
| wsrep_cluster_status             | Primary                                                                                                                                        |
| wsrep_connected                  | ON                                                                                                                                             |
| wsrep_local_bf_aborts            | 0                                                                                                                                              |
| wsrep_local_index                | 2                                                                                                                                              |
| wsrep_provider_capabilities      | :MULTI_MASTER:CERTIFICATION:PARALLEL_APPLYING:TRX_REPLAY:ISOLATION:PAUSE:CAUSAL_READS:INCREMENTAL_WRITESET:UNORDERED:PREORDERED:STREAMING:NBO: |
| wsrep_provider_name              | Galera                                                                                                                                         |
| wsrep_provider_vendor            | Codership Oy <info@codership.com> (modified by Percona <https://percona.com/>)                                                                 |
| wsrep_provider_version           | 4.17(aa2461d)                                                                                                                                  |
| wsrep_ready                      | ON                                                                                                                                             |
| wsrep_thread_count               | 9                                                                                                                                              |
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
79 rows in set (0.00 sec)


MySQL [(none)]> SELECT hostgroup_id,hostname,port,status FROM runtime_mysql_servers;
+--------------+-------------+------+--------+
| hostgroup_id | hostname    | port | status |
+--------------+-------------+------+--------+
| 0            | 10.110.0.50 | 3306 | ONLINE |
| 0            | 10.110.0.51 | 3306 | ONLINE |
| 0            | 10.110.0.52 | 3306 | ONLINE |
+--------------+-------------+------+--------+
3 rows in set (0.002 sec)



```

Немножко скринов.

![](<images/Screenshot from 2024-09-14 20-27-40.png>)

![alt text](<images/Screenshot from 2024-09-14 20-28-08.png>)

![alt text](<images/Screenshot from 2024-09-14 20-29-04.png>)

![alt text](<images/Screenshot from 2024-09-14 20-46-55.png>)

## Задание выполнено!




