# Домашнее задание: реализация кластера postgreSQL с помощью patroni

## Цель: Перевести БД веб проекта на кластер postgreSQL с ипользованием patroni, etcd/consul/zookeeper и haproxy/pgbouncer

## Описание/Пошаговая инструкция выполнения домашнего задания:

Перевести БД веб проекта на кластер postgreSQL с ипользованием patroni, etcd/consul/zookeeper и haproxy/pgbouncer.

## Критерии оценки:

Статус "Принято" ставится при выполнении перечисленных требований.






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


Затем перейдя в каталог ansible выполнить ansible-playbook playbooks/000_start.yml

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

nodedb {
otus-nodedb-1: 10.110.0.50
otus-nodedb-1: 10.110.0.51
otus-nodedb-1: 10.110.0.52
}

nodeshaproxybackend {
otus-backend-haproxy-1 ansible_host=10.110.0.20
otus-backend-haproxy-2 ansible_host=10.110.0.21
}

nodesetcdbackend {
otus-backend-etcd-1 ansible_host=10.110.0.30
otus-backend-etcd-2 ansible_host=10.110.0.31
otus-backend-etcd-3 ansible_host=10.110.0.32
}

```                               


Сделана подсеть для менеджмента через bastion host и две отдельных подсети для web трафика и для трафика баз данных
Добавлен еще один frontend и yc nlb балансировщик.


#### Стенд созданный opentofu

``` shell

OOutputs:

lb_ip_address = [
    {
        external_address_spec = [
            {
                address    = "51.250.42.17"
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
        id                      = "epdm12rd9u5h24ga7638"
        internal_data_ip_manage = [
            "10.201.0.20",
        ]
        name                    = "otus-bastion-1"
        public_ip               = [
            "158.160.28.15",
        ]
    },
]
otus-frontend = [
    {
        fqdn                    = "otus-frontend-1.ru-central1.internal"
        id                      = "epdglqn58eaqa88u9nok"
        internal_data_ip_manage = [
            "10.200.0.200",
        ]
        internal_data_ip_web    = [
            "10.100.0.200",
        ]
        name                    = "otus-frontend-1"
        public_ip               = [
            "130.193.55.121",
        ]
    },
    {
        fqdn                    = "otus-frontend-2.ru-central1.internal"
        id                      = "epd54tjnv3p1lppvnvn8"
        internal_data_ip_manage = [
            "10.200.0.201",
        ]
        internal_data_ip_web    = [
            "10.100.0.201",
        ]
        name                    = "otus-frontend-2"
        public_ip               = [
            "89.169.175.185",
        ]
    },
]
otus-nodedb = [
    {
        fqdn                    = "otus-nodedb-1.ru-central1.internal"
        id                      = "epd1mer7d14971hbait0"
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
        id                      = "epdg70u4qadbdl5f6v4f"
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
        id                      = "epdog27fa06dble0nfcn"
        internal_data_ip_db     = [
            "10.110.0.52",
        ]
        internal_data_ip_manage = [
            "10.200.0.52",
        ]
        name                    = "otus-nodedb-3"
    },
]
otus-nodeetcdbackend = [
    {
        fqdn                    = "otus-backend-etcd-1.ru-central1.internal"
        id                      = "epdq022qgif77qmtj5mq"
        internal_data_ip_db     = [
            "10.110.0.30",
        ]
        internal_data_ip_manage = [
            "10.200.0.30",
        ]
        name                    = "otus-backend-etcd-1"
    },
    {
        fqdn                    = "otus-backend-etcd-2.ru-central1.internal"
        id                      = "epdg7oo69mn54i9u1at6"
        internal_data_ip_db     = [
            "10.110.0.31",
        ]
        internal_data_ip_manage = [
            "10.200.0.31",
        ]
        name                    = "otus-backend-etcd-2"
    },
    {
        fqdn                    = "otus-backend-etcd-3.ru-central1.internal"
        id                      = "epd1mq295dsrgjplg7o1"
        internal_data_ip_db     = [
            "10.110.0.32",
        ]
        internal_data_ip_manage = [
            "10.200.0.32",
        ]
        name                    = "otus-backend-etcd-3"
    },
]
otus-nodehaproxybackend = [
    {
        fqdn                    = "otus-backend-haproxy-1.ru-central1.internal"
        id                      = "epdo7av7681boaol4sfa"
        internal_data_ip_db     = [
            "10.110.0.20",
        ]
        internal_data_ip_manage = [
            "10.200.0.20",
        ]
        name                    = "otus-backend-haproxy-1"
    },
    {
        fqdn                    = "otus-backend-haproxy-2.ru-central1.internal"
        id                      = "epdhqe4ln1fki912ii8f"
        internal_data_ip_db     = [
            "10.110.0.21",
        ]
        internal_data_ip_manage = [
            "10.200.0.21",
        ]
        name                    = "otus-backend-haproxy-2"
    },
]
otus-nodeweb = [
    {
        fqdn                    = "otus-nodeweb-1.ru-central1.internal"
        id                      = "epdjvf4uqk770q2nrdoq"
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
        id                      = "epdtpigl6qfovckqg8is"
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
        id                      = "epdgvqgmic1qbdte70c1"
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

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/10_postgresqlclusterjoomla$ tree
.
├── ansible
│   ├── ansible.cfg
│   ├── inventories
│   │   └── hosts
│   ├── playbooks
│   │   ├── 000_start.yml
│   │   ├── 001_bastion.yml
│   │   ├── 002_base.yml
│   │   ├── 003_nginx_frontend.yml
│   │   ├── 004_backend_glusterfs.yml
│   │   ├── 005_nginx_backend.yml
│   │   ├── 006_haproxybackend.yml
│   │   ├── 007_dcsbackend.yml
│   │   ├── 008_postgrespatroni.yml
│   │   └── test.yml
│   ├── requirements.yml
│   ├── roles
│   │   ├── 001_bastion
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   ├── main.yml
│   │   │   │   └── nginx.yml
│   │   │   ├── templates
│   │   │   │   ├── app.conf.j2
│   │   │   │   └── nginx.conf.j2
│   │   │   └── vars
│   │   │       └── main.yml
│   │   ├── 002_base
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── 003_nginx_frontend
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   ├── templates
│   │   │   │   ├── app.conf.j2
│   │   │   │   └── nginx.conf.j2
│   │   │   └── vars
│   │   │       └── main.yml
│   │   ├── 004_backend_glusterfs
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   ├── templates
│   │   │   │   └── nginx.conf.j2
│   │   │   └── vars
│   │   │       └── main.yml
│   │   ├── 005_nginx_backend
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   ├── joomla.yml
│   │   │   │   ├── main.yml
│   │   │   │   ├── php-fpm.yml
│   │   │   │   └── wordpress.yml
│   │   │   ├── templates
│   │   │   │   ├── app.conf.j2
│   │   │   │   ├── index.html.j2
│   │   │   │   ├── index.php.j2
│   │   │   │   ├── nginx.conf.j2
│   │   │   │   └── wp-config.php.j2
│   │   │   └── vars
│   │   │       └── main.yml
│   │   ├── 006_haproxybackend
│   │   │   ├── handlers
│   │   │   ├── tasks
│   │   │   │   ├── haproxy.yml
│   │   │   │   ├── keepalived.yml
│   │   │   │   └── main.yml
│   │   │   ├── templates
│   │   │   │   ├── haproxy.cfg
│   │   │   │   └── keepalived.conf.j2
│   │   │   └── vars
│   │   │       └── main.yml
│   │   ├── 007_dcsbackend
│   │   │   ├── handlers
│   │   │   ├── tasks
│   │   │   │   ├── etcd3.yml
│   │   │   │   └── main.yml
│   │   │   └── vars
│   │   │       └── main.yml
│   │   └── 008_postgrespatroni
│   │       ├── files
│   │       │   └── patroni.service
│   │       ├── tasks
│   │       │   ├── consul.yml
│   │       │   ├── main.yml
│   │       │   ├── patroni.yml
│   │       │   └── postgresql.yml
│   │       ├── templates
│   │       │   ├── consul-client.json
│   │       │   ├── consul-server.json
│   │       │   ├── patroni.yml.j2
│   │       │   └── temp
│   │       │       ├── config.yml.in
│   │       │       ├── dcs.yml
│   │       │       ├── del
│   │       │       └── testpatroni.yml
│   │       └── vars
│   │           └── main.yml
│   ├── terraform.tfstate
│   └── vars
│       └── allnodes_ip_vars.yml
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
    │   └── waitssh.sh
    ├── security-group.tf
    ├── templates
    │   ├── allnodes_ip_address.tpl
    │   └── inventory.tpl
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    ├── variables.tf
    ├── vm-backend_etcd.tf
    ├── vm-backend_haproxy.tf
    ├── vm-bastion.tf
    ├── vm-frontend.tf
    ├── vm-nlb.tf
    ├── vm-nodedb.tf
    └── vm-nodeweb.tf

46 directories, 88 files


```

Весь проект разделен на пять частей

- 000_start - запуск всех плейбуков
- 001_bastion - настройка хоста bastion - задел на будущее - в данной работе используется готовый nat instane
- 002_base - базовые пакеты chronyd сетевая аналитика
- 003_nginx-frontend - базовая настройка nginx для апстрим  - используется round-robin
- 004_backend_glusterfs - создание кластеризованой реплицируемой fs на базе glusterfs - несколько отошел от ДЗ - не хотелось повторять ДЗ 2
- 005_nginx_backend - относительно предыдущего ДЗ перешел с CMS Wordpress на Joomla, так как WP из коробки не поддерживает postgresql
- 006_haproxybackend - балансировка подключений а патрони серверам, плюс keepalived - адрес 10.110.0.100
- 007_dcsbackend- установка кластера ETCD.
- 008_postgrespatroni - установка patroni управляемого кластера postgres


#### Листинг работы opentofu и ansible

<details>

```shell

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/10_postgresqlclusterjoomla/ansible$ ansible-playbook playbooks/test.yml 

PLAY [Playbook of 001_bastion] **********************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************
ok: [otus-bastion-1]

TASK [001_bastion : Set hostname] *******************************************************************************************************************************
ok: [otus-bastion-1]

TASK [001_bastion : set timezone] *******************************************************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : Synchronize datetime | Install chrony] ******************************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : Synchronize datetime | Turn on chronyd] *****************************************************************************************************
ok: [otus-bastion-1]

TASK [001_bastion : install base tools] *************************************************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : Add Nginx to Redirect backend monitoring] ***************************************************************************************************
included: /home/sincere/otus/02_highload/lessons/10_postgresqlclusterjoomla/ansible/roles/001_bastion/tasks/nginx.yml for otus-bastion-1

TASK [001_bastion : Check Base Packages] ************************************************************************************************************************
changed: [otus-bastion-1] => (item={'package': 'nginx', 'state': 'latest'})
ok: [otus-bastion-1] => (item={'package': 'openssl', 'state': 'present'})

TASK [001_bastion : Create a user nginx with a home directory] **************************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : adding existing user 'nginxuser' to group sudo] *********************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : Remove DefaultSite (delete file)] ***********************************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : Delete content & directory] *****************************************************************************************************************
changed: [otus-bastion-1] => (item=/etc/nginx/sites-available)
changed: [otus-bastion-1] => (item=/etc/nginx/sites-enabled)

TASK [001_bastion : Create conf directory] **********************************************************************************************************************
changed: [otus-bastion-1] => (item=/etc/nginx/sites-available)
changed: [otus-bastion-1] => (item=/etc/nginx/sites-enabled)

TASK [001_bastion : Create an app directory if it does not exist] ***********************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : Copy Nginx site-configuration file.] ********************************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : Copy Nginx site-configuration file.] ********************************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : Check Nginx Sites File Symlink] *************************************************************************************************************
changed: [otus-bastion-1]

TASK [001_bastion : restart nginx] ******************************************************************************************************************************
changed: [otus-bastion-1]

RUNNING HANDLER [001_bastion : restart nginx] *******************************************************************************************************************
changed: [otus-bastion-1]

PLAY [Playbook of 002_base] *************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************
ok: [otus-bastion-1]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-nodedb-2]
ok: [otus-frontend-2]
ok: [otus-frontend-1]
ok: [otus-nodedb-3]
ok: [otus-backend-haproxy-1]
ok: [otus-nodedb-1]
ok: [otus-backend-haproxy-2]
ok: [otus-backend-etcd-2]
ok: [otus-backend-etcd-1]
ok: [otus-backend-etcd-3]

TASK [Include main variables] ***********************************************************************************************************************************
ok: [otus-bastion-1]
ok: [otus-frontend-1]
ok: [otus-frontend-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-nodedb-1]
ok: [otus-nodedb-2]
ok: [otus-nodedb-3]
ok: [otus-backend-haproxy-1]
ok: [otus-backend-haproxy-2]
ok: [otus-backend-etcd-1]
ok: [otus-backend-etcd-2]
ok: [otus-backend-etcd-3]

TASK [002_base : Set hostname] **********************************************************************************************************************************
ok: [otus-bastion-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]
ok: [otus-nodedb-2]
ok: [otus-nodedb-3]
ok: [otus-backend-haproxy-1]
ok: [otus-frontend-2]
ok: [otus-frontend-1]
ok: [otus-backend-haproxy-2]
ok: [otus-backend-etcd-2]
ok: [otus-nodedb-1]
ok: [otus-backend-etcd-1]
ok: [otus-backend-etcd-3]

TASK [002_base : set timezone] **********************************************************************************************************************************
changed: [otus-bastion-1]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]
changed: [otus-nodedb-2]
changed: [otus-frontend-1]
changed: [otus-frontend-2]
changed: [otus-backend-haproxy-1]
changed: [otus-nodedb-3]
changed: [otus-backend-haproxy-2]
changed: [otus-backend-etcd-2]
changed: [otus-nodedb-1]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [002_base : Fill /etc/hosts from allnodes_ip_vars] *********************************************************************************************************
changed: [otus-bastion-1] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-frontend-1] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-frontend-2] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-frontend-1] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-frontend-2] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-frontend-1] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-frontend-2] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-bastion-1] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-frontend-1] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-bastion-1] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-bastion-1] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-frontend-2] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-frontend-1] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-frontend-2] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-frontend-1] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-frontend-2] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-nodeweb-2] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-nodeweb-1] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-nodedb-2] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-frontend-1] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-nodedb-2] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-nodedb-2] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-frontend-2] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-nodedb-1] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-nodedb-2] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-nodedb-2] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-nodedb-2] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-frontend-1] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-nodedb-2] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-nodedb-1] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-frontend-2] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-nodedb-2] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-nodedb-2] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-nodeweb-3] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-frontend-1] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-nodedb-2] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-frontend-2] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-nodedb-3] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodedb-1] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-nodedb-2] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-nodedb-3] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-nodedb-2] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-nodedb-2] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-nodedb-3] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-frontend-1] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodedb-3] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-frontend-2] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-nodedb-1] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-nodedb-3] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-nodedb-3] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-frontend-1] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-frontend-2] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-nodedb-1] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-nodedb-3] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-nodedb-3] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-frontend-2] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-frontend-1] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-nodedb-1] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-nodedb-3] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-nodedb-3] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-frontend-2] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-frontend-1] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-nodedb-1] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-nodedb-3] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodedb-3] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-backend-haproxy-1] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodedb-3] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-nodedb-1] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-frontend-1', 'ip': '10.100.0.200', 'int': 'web'})
changed: [otus-nodedb-1] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-nodedb-1] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-frontend-2', 'ip': '10.100.0.201', 'int': 'web'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-backend-haproxy-2] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-backend-etcd-2] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-nodedb-1] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-nodeweb-1', 'ip': '10.100.0.10', 'int': 'web'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-nodedb-1] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-nodeweb-2', 'ip': '10.100.0.11', 'int': 'web'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-nodedb-1] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-nodeweb-3', 'ip': '10.100.0.12', 'int': 'web'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-nodedb-1', 'ip': '10.110.0.50', 'int': 'db'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-nodedb-2', 'ip': '10.110.0.51', 'int': 'db'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-nodedb-3', 'ip': '10.110.0.52', 'int': 'db'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-backend-haproxy-1', 'ip': '10.110.0.20', 'int': 'db'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-backend-haproxy-2', 'ip': '10.110.0.21', 'int': 'db'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-backend-etcd-1', 'ip': '10.110.0.30', 'int': 'db'})
changed: [otus-backend-etcd-1] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-backend-etcd-2', 'ip': '10.110.0.31', 'int': 'db'})
changed: [otus-backend-etcd-3] => (item={'name': 'otus-backend-etcd-3', 'ip': '10.110.0.32', 'int': 'db'})

TASK [002_base : Update apt cache] ******************************************************************************************************************************
ok: [otus-bastion-1]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-backend-haproxy-1]
changed: [otus-backend-haproxy-2]
changed: [otus-backend-etcd-2]
changed: [otus-frontend-1]
changed: [otus-frontend-2]
changed: [otus-nodedb-1]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [002_base : Synchronize datetime | Install chrony] *********************************************************************************************************
ok: [otus-bastion-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-backend-haproxy-1]
changed: [otus-backend-haproxy-2]
changed: [otus-frontend-2]
changed: [otus-frontend-1]
changed: [otus-backend-etcd-2]
changed: [otus-nodedb-1]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [002_base : Synchronize datetime | Turn on chronyd] ********************************************************************************************************
ok: [otus-bastion-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]
ok: [otus-nodedb-2]
ok: [otus-backend-haproxy-1]
ok: [otus-nodedb-3]
ok: [otus-frontend-1]
ok: [otus-backend-haproxy-2]
ok: [otus-frontend-2]
ok: [otus-backend-etcd-2]
ok: [otus-nodedb-1]
ok: [otus-backend-etcd-1]
ok: [otus-backend-etcd-3]

TASK [002_base : install base tools] ****************************************************************************************************************************
ok: [otus-bastion-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-1]
changed: [otus-nodedb-2]
changed: [otus-frontend-2]
changed: [otus-nodedb-3]
changed: [otus-frontend-1]
changed: [otus-backend-haproxy-1]
changed: [otus-backend-haproxy-2]
changed: [otus-nodedb-1]
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

PLAY [Playbook of test_003] *************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************
ok: [otus-frontend-1]
ok: [otus-frontend-2]

TASK [003_nginx_frontend : Check Base Packages] *****************************************************************************************************************
changed: [otus-frontend-2] => (item={'package': 'nginx', 'state': 'latest'})
changed: [otus-frontend-1] => (item={'package': 'nginx', 'state': 'latest'})
ok: [otus-frontend-2] => (item={'package': 'openssl', 'state': 'present'})
ok: [otus-frontend-1] => (item={'package': 'openssl', 'state': 'present'})

TASK [003_nginx_frontend : Create a user nginx with a home directory] *******************************************************************************************
changed: [otus-frontend-1]
changed: [otus-frontend-2]

TASK [003_nginx_frontend : adding existing user 'nginxuser' to group sudo] **************************************************************************************
changed: [otus-frontend-2]
changed: [otus-frontend-1]

TASK [003_nginx_frontend : Remove DefaultSite (delete file)] ****************************************************************************************************
changed: [otus-frontend-1]
changed: [otus-frontend-2]

TASK [003_nginx_frontend : Delete content & directory] **********************************************************************************************************
changed: [otus-frontend-2] => (item=/etc/nginx/sites-available)
changed: [otus-frontend-1] => (item=/etc/nginx/sites-available)
changed: [otus-frontend-2] => (item=/etc/nginx/sites-enabled)
changed: [otus-frontend-1] => (item=/etc/nginx/sites-enabled)

TASK [003_nginx_frontend : Create conf directory] ***************************************************************************************************************
changed: [otus-frontend-1] => (item=/etc/nginx/sites-available)
changed: [otus-frontend-2] => (item=/etc/nginx/sites-available)
changed: [otus-frontend-1] => (item=/etc/nginx/sites-enabled)
changed: [otus-frontend-2] => (item=/etc/nginx/sites-enabled)

TASK [003_nginx_frontend : Create an app directory if it does not exist] ****************************************************************************************
changed: [otus-frontend-1]
changed: [otus-frontend-2]

TASK [003_nginx_frontend : Copy Nginx site-configuration file.] *************************************************************************************************
changed: [otus-frontend-2]
changed: [otus-frontend-1]

TASK [003_nginx_frontend : Copy Nginx site-configuration file.] *************************************************************************************************
changed: [otus-frontend-2]
changed: [otus-frontend-1]

TASK [003_nginx_frontend : Check Nginx Sites File Symlink] ******************************************************************************************************
changed: [otus-frontend-1]
changed: [otus-frontend-2]

TASK [003_nginx_frontend : restart nginx] ***********************************************************************************************************************
changed: [otus-frontend-2]
changed: [otus-frontend-1]

RUNNING HANDLER [003_nginx_frontend : restart nginx] ************************************************************************************************************
changed: [otus-frontend-1]
changed: [otus-frontend-2]

PLAY [Playbook of test_004] *************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]
ok: [otus-nodeweb-1]

TASK [004_backend_glusterfs : Add node1 to /etc/hosts] **********************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]

TASK [004_backend_glusterfs : Add node1 to /etc/hosts] **********************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-3]
ok: [otus-nodeweb-2]

TASK [004_backend_glusterfs : Add node1 to /etc/hosts] **********************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]

TASK [004_backend_glusterfs : Install mkfs.xfs] *****************************************************************************************************************
changed: [otus-nodeweb-3] => (item={'package': 'xfsprogs', 'state': 'latest'})
changed: [otus-nodeweb-1] => (item={'package': 'xfsprogs', 'state': 'latest'})
changed: [otus-nodeweb-2] => (item={'package': 'xfsprogs', 'state': 'latest'})

TASK [004_backend_glusterfs : Configuring xfs on /dev/vdb] ******************************************************************************************************
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-2]

TASK [004_backend_glusterfs : Ensure Gluster mount directories exist.] ******************************************************************************************
changed: [otus-nodeweb-2] => (item=/glusterfs)
changed: [otus-nodeweb-3] => (item=/glusterfs)
changed: [otus-nodeweb-1] => (item=/glusterfs)
changed: [otus-nodeweb-1] => (item=/glusterfs/br0)
changed: [otus-nodeweb-2] => (item=/glusterfs/br0)
changed: [otus-nodeweb-3] => (item=/glusterfs/br0)

TASK [004_backend_glusterfs : Ensure Gluster disk is mounted.] **************************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]

TASK [004_backend_glusterfs : Install GlusterFS server & client] ************************************************************************************************
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]

TASK [004_backend_glusterfs : Restart GlusterFS] ****************************************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-2]

TASK [004_backend_glusterfs : Create a trusted storage pool] ****************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [004_backend_glusterfs : Ensure Gluster mount volume directories exist.] ***********************************************************************************
changed: [otus-nodeweb-1] => (item=/glusterfs/br0/g0)
changed: [otus-nodeweb-2] => (item=/glusterfs/br0/g0)
changed: [otus-nodeweb-3] => (item=/glusterfs/br0/g0)
changed: [otus-nodeweb-2] => (item=/opt/gfsvol)
changed: [otus-nodeweb-1] => (item=/opt/gfsvol)
changed: [otus-nodeweb-3] => (item=/opt/gfsvol)

TASK [004_backend_glusterfs : Create gluster volume] ************************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [004_backend_glusterfs : Start gluster volume] *************************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
ok: [otus-nodeweb-1]

TASK [004_backend_glusterfs : Ensure Gluster volume is mounted.] ************************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]

RUNNING HANDLER [004_backend_glusterfs : daemon-reload] *********************************************************************************************************
ok: [otus-nodeweb-3]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-1]

PLAY [Playbook of test_005] *************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************
ok: [otus-nodeweb-1]
ok: [otus-nodeweb-2]
ok: [otus-nodeweb-3]

TASK [005_nginx_backend : Check Base Packages] ******************************************************************************************************************
changed: [otus-nodeweb-3] => (item={'package': 'nginx', 'state': 'latest'})
changed: [otus-nodeweb-2] => (item={'package': 'nginx', 'state': 'latest'})
changed: [otus-nodeweb-1] => (item={'package': 'nginx', 'state': 'latest'})

TASK [005_nginx_backend : Create a user nginx with a home directory] ********************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-2]

TASK [005_nginx_backend : adding existing user 'nginxuser' to group sudo] ***************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-2]

TASK [005_nginx_backend : Remove DefaultSite (delete file)] *****************************************************************************************************
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]

TASK [005_nginx_backend : Delete content & directory] ***********************************************************************************************************
changed: [otus-nodeweb-3] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-3] => (item=/etc/nginx/sites-enabled)
changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled)
changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled)

TASK [005_nginx_backend : Create conf directory] ****************************************************************************************************************
changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-3] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-available)
changed: [otus-nodeweb-1] => (item=/etc/nginx/sites-enabled)
changed: [otus-nodeweb-3] => (item=/etc/nginx/sites-enabled)
changed: [otus-nodeweb-2] => (item=/etc/nginx/sites-enabled)

TASK [005_nginx_backend : Create an app directory if it does not exist] *****************************************************************************************
changed: [otus-nodeweb-1]
ok: [otus-nodeweb-3]
ok: [otus-nodeweb-2]

TASK [005_nginx_backend : Copy Nginx index file.] ***************************************************************************************************************
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Copy Nginx site-configuration file.] **************************************************************************************************
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-3]

TASK [005_nginx_backend : Copy Nginx site-configuration file.] **************************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]

TASK [005_nginx_backend : Check Nginx Sites File Symlink] *******************************************************************************************************
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Include php-fpm service] **************************************************************************************************************
included: /home/sincere/otus/02_highload/lessons/10_postgresqlclusterjoomla/ansible/roles/005_nginx_backend/tasks/php-fpm.yml for otus-nodeweb-1, otus-nodeweb-2, otus-nodeweb-3

TASK [005_nginx_backend : Install PHP-FPM Debian] ***************************************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]

TASK [005_nginx_backend : Start php-fpm service] ****************************************************************************************************************
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]

TASK [005_nginx_backend : Include wordpress section] ************************************************************************************************************
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]

TASK [005_nginx_backend : Include joomla section] ***************************************************************************************************************
included: /home/sincere/otus/02_highload/lessons/10_postgresqlclusterjoomla/ansible/roles/005_nginx_backend/tasks/joomla.yml for otus-nodeweb-1, otus-nodeweb-2, otus-nodeweb-3

TASK [005_nginx_backend : Joomla | Remove elements from /var/www/html/] *****************************************************************************************
skipping: [otus-nodeweb-1]
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]

TASK [005_nginx_backend : Joomla | Create directory] ************************************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Joomla | Extract archive in /opt/gfsvol/cms] ******************************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Joomla | Change ownership of installation directory] **********************************************************************************
skipping: [otus-nodeweb-2]
skipping: [otus-nodeweb-3]
changed: [otus-nodeweb-1]

TASK [005_nginx_backend : Installing dependencies] **************************************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]

RUNNING HANDLER [005_nginx_backend : restart nginx] *************************************************************************************************************
changed: [otus-nodeweb-3]
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]

RUNNING HANDLER [005_nginx_backend : reload nginx] **************************************************************************************************************
changed: [otus-nodeweb-1]
changed: [otus-nodeweb-2]
changed: [otus-nodeweb-3]

PLAY [Playbook of 006_haproxybackend] ***************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************
ok: [otus-backend-haproxy-2]
ok: [otus-backend-haproxy-1]

TASK [006_haproxybackend : HAPROXY] *****************************************************************************************************************************
included: /home/sincere/otus/02_highload/lessons/10_postgresqlclusterjoomla/ansible/roles/006_haproxybackend/tasks/haproxy.yml for otus-backend-haproxy-1, otus-backend-haproxy-2

TASK [006_haproxybackend : Install haproxy package] *************************************************************************************************************
changed: [otus-backend-haproxy-1]
changed: [otus-backend-haproxy-2]

TASK [006_haproxybackend : Deploy haproxy configuration] ********************************************************************************************************
changed: [otus-backend-haproxy-1]
changed: [otus-backend-haproxy-2]

TASK [006_haproxybackend : systemctl daemon-reload / start haproxy] *********************************************************************************************
changed: [otus-backend-haproxy-1]
changed: [otus-backend-haproxy-2]

TASK [006_haproxybackend : KEEPALIVED] **************************************************************************************************************************
included: /home/sincere/otus/02_highload/lessons/10_postgresqlclusterjoomla/ansible/roles/006_haproxybackend/tasks/keepalived.yml for otus-backend-haproxy-1, otus-backend-haproxy-2

TASK [006_haproxybackend : ansible.posix.sysctl] ****************************************************************************************************************
changed: [otus-backend-haproxy-1]
changed: [otus-backend-haproxy-2]

TASK [006_haproxybackend : ansible.posix.sysctl] ****************************************************************************************************************
changed: [otus-backend-haproxy-2]
changed: [otus-backend-haproxy-1]

TASK [006_haproxybackend : Install keepalived package] **********************************************************************************************************
changed: [otus-backend-haproxy-2]
changed: [otus-backend-haproxy-1]

TASK [006_haproxybackend : Deploy haproxy configuration] ********************************************************************************************************
changed: [otus-backend-haproxy-2]
changed: [otus-backend-haproxy-1]

TASK [006_haproxybackend : systemctl daemon-reload / start haproxy] *********************************************************************************************
changed: [otus-backend-haproxy-1]
changed: [otus-backend-haproxy-2]

PLAY [Playbook of 007_dcsbackend] *******************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************
ok: [otus-backend-etcd-2]
ok: [otus-backend-etcd-1]
ok: [otus-backend-etcd-3]

TASK [007_dcsbackend : Add Needed dcs service] ******************************************************************************************************************
included: /home/sincere/otus/02_highload/lessons/10_postgresqlclusterjoomla/ansible/roles/007_dcsbackend/tasks/etcd3.yml for otus-backend-etcd-1, otus-backend-etcd-2, otus-backend-etcd-3

TASK [007_dcsbackend : Uninstall etcd server] *******************************************************************************************************************
ok: [otus-backend-etcd-2]
ok: [otus-backend-etcd-3]
ok: [otus-backend-etcd-1]

TASK [007_dcsbackend : Install etcd server] *********************************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [007_dcsbackend : Install etcd client] *********************************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-3]
changed: [otus-backend-etcd-1]

TASK [007_dcsbackend : Set member name] *************************************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [007_dcsbackend : Set data directory] **********************************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-3]
changed: [otus-backend-etcd-1]

TASK [007_dcsbackend : Listen for other cluster peers] **********************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [007_dcsbackend : Setup advertised peer communication URL] *************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [007_dcsbackend : Enable client listen interface] **********************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [007_dcsbackend : Advertise client interface] **************************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [007_dcsbackend : Setup URLs of initials members] **********************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [007_dcsbackend : Set ETCD Cluster Token] ******************************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-3]
changed: [otus-backend-etcd-1]

TASK [007_dcsbackend : Set ETCD Cluster Initial State] **********************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-1]
changed: [otus-backend-etcd-3]

TASK [007_dcsbackend : Set ETCD Cluster Initial State] **********************************************************************************************************
skipping: [otus-backend-etcd-1]
skipping: [otus-backend-etcd-2]
skipping: [otus-backend-etcd-3]

TASK [007_dcsbackend : Set ETCD Election Timeout] ***************************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-3]
changed: [otus-backend-etcd-1]

TASK [007_dcsbackend : Set ETCD_HEARTBEAT_INTERVAL] *************************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-3]
changed: [otus-backend-etcd-1]

TASK [007_dcsbackend : systemctl daemon-reload / start etcd] ****************************************************************************************************
changed: [otus-backend-etcd-2]
changed: [otus-backend-etcd-3]
changed: [otus-backend-etcd-1]

TASK [007_dcsbackend : Wait for port 2379 to become open on the host] *******************************************************************************************
ok: [otus-backend-etcd-2]
ok: [otus-backend-etcd-3]
ok: [otus-backend-etcd-1]

TASK [007_dcsbackend : Wait until the etcd cluster is healthy] **************************************************************************************************
ok: [otus-backend-etcd-2]
ok: [otus-backend-etcd-3]
ok: [otus-backend-etcd-1]

TASK [007_dcsbackend : cluster health] **************************************************************************************************************************
ok: [otus-backend-etcd-1] => {
    "msg": "http://otus-backend-etcd-1:2379 is healthy: successfully committed proposal: took = 12.651875ms\n"
}
ok: [otus-backend-etcd-2] => {
    "msg": "http://otus-backend-etcd-2:2379 is healthy: successfully committed proposal: took = 19.520906ms\n"
}
ok: [otus-backend-etcd-3] => {
    "msg": "http://otus-backend-etcd-3:2379 is healthy: successfully committed proposal: took = 10.511051ms\n"
}

TASK [007_dcsbackend : Info about the etcd cluster is state] ****************************************************************************************************
ok: [otus-backend-etcd-2]
ok: [otus-backend-etcd-1]
ok: [otus-backend-etcd-3]

TASK [007_dcsbackend : cluster state] ***************************************************************************************************************************
ok: [otus-backend-etcd-1] => {
    "msg": "+---------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+\n|            ENDPOINT             |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |\n+---------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+\n| http://otus-backend-etcd-1:2379 | 9dedb9df17f4d452 |  3.4.23 |   20 kB |     false |      false |         2 |          8 |                  8 |        |\n+---------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+\n"
}
ok: [otus-backend-etcd-2] => {
    "msg": "+---------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+\n|            ENDPOINT             |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |\n+---------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+\n| http://otus-backend-etcd-2:2379 | 76271b93c57de805 |  3.4.23 |   20 kB |      true |      false |         2 |          8 |                  8 |        |\n+---------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+\n"
}
ok: [otus-backend-etcd-3] => {
    "msg": "+---------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+\n|            ENDPOINT             |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |\n+---------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+\n| http://otus-backend-etcd-3:2379 | dc96f684ae2bc820 |  3.4.23 |   20 kB |     false |      false |         2 |          8 |                  8 |        |\n+---------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+\n"
}

PLAY [Playbook of 008_postgrespatroni] **************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************
ok: [otus-nodedb-2]
ok: [otus-nodedb-3]
ok: [otus-nodedb-1]

TASK [008_postgrespatroni : Install PostgreSQL] *****************************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [008_postgrespatroni : Install PostgreSQL] *****************************************************************************************************************
included: /home/sincere/otus/02_highload/lessons/10_postgresqlclusterjoomla/ansible/roles/008_postgrespatroni/tasks/postgresql.yml for otus-nodedb-1, otus-nodedb-2, otus-nodedb-3

TASK [008_postgrespatroni : Install gnupg] **********************************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Install generally useful packages] **************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Add PostgreSQL apt key] *************************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Add PostgreSQL repository] **********************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Install PostgreSQL] *****************************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : check init] *************************************************************************************************************************
ok: [otus-nodedb-2]
ok: [otus-nodedb-1]
ok: [otus-nodedb-3]

TASK [008_postgrespatroni : Recursively remove directory postgres database] *************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-1]
changed: [otus-nodedb-3]

TASK [008_postgrespatroni : Change file ownership, group and permissions] ***************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Disable auto creation of PostgreSQL clusters] ***************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-1]
changed: [otus-nodedb-3]

TASK [008_postgrespatroni : systemctl disabled postgresql] ******************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Install Patroni] ********************************************************************************************************************
included: /home/sincere/otus/02_highload/lessons/10_postgresqlclusterjoomla/ansible/roles/008_postgrespatroni/tasks/patroni.yml for otus-nodedb-1, otus-nodedb-2, otus-nodedb-3

TASK [008_postgrespatroni : install python3-psycopg2] ***********************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Install generally useful packages python3 for patroni] ******************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Install patroni] ********************************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Install multi python packages with version specifiers  - testresources] *************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Install multi python packages with version specifiers  - setuptools] ****************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Install consul client package] ******************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [008_postgrespatroni : Install zookeeper client package] ***************************************************************************************************
skipping: [otus-nodedb-1]
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]

TASK [008_postgrespatroni : Install etcd client package] ********************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Change file ownership, group and permissions] ***************************************************************************************
ok: [otus-nodedb-2]
ok: [otus-nodedb-1]
ok: [otus-nodedb-3]

TASK [008_postgrespatroni : Change file ownership, group and permissions] ***************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-1]
changed: [otus-nodedb-3]

TASK [008_postgrespatroni : Set patroni.yml template] ***********************************************************************************************************
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : force systemd to reread configs and patroni start] **********************************************************************************
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
changed: [otus-nodedb-1]

TASK [008_postgrespatroni : Wait for port 5432 to become open on the host] **************************************************************************************
skipping: [otus-nodedb-2]
skipping: [otus-nodedb-3]
ok: [otus-nodedb-1]

TASK [008_postgrespatroni : Pause 10 seconds to let bootstrap start] ********************************************************************************************
Pausing for 10 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [otus-nodedb-1]

TASK [008_postgrespatroni : force systemd to reread configs and patroni start] **********************************************************************************
skipping: [otus-nodedb-1]
changed: [otus-nodedb-2]
changed: [otus-nodedb-3]

PLAY RECAP ******************************************************************************************************************************************************
otus-backend-etcd-1        : ok=31   changed=19   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
otus-backend-etcd-2        : ok=31   changed=19   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
otus-backend-etcd-3        : ok=31   changed=19   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
otus-backend-haproxy-1     : ok=20   changed=13   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
otus-backend-haproxy-2     : ok=20   changed=13   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
otus-bastion-1             : ok=28   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
otus-frontend-1            : ok=22   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
otus-frontend-2            : ok=22   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
otus-nodedb-1              : ok=34   changed=23   unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
otus-nodedb-2              : ok=32   changed=23   unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
otus-nodedb-3              : ok=32   changed=23   unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
otus-nodeweb-1             : ok=47   changed=34   unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
otus-nodeweb-2             : ok=41   changed=28   unreachable=0    failed=0    skipped=8    rescued=0    ignored=0   
otus-nodeweb-3             : ok=41   changed=28   unreachable=0    failed=0    skipped=8    rescued=0    ignored=0   

```

</details>



Итогом запуска станет настроенный подготовленный для настройки CMS Joomla на интерфейсе nlb балансировщика.

На интерфейсе ip bastion:7000 - увидим интерфейс haproxy со статусом нод postgresql

Но по порядку.

Смотрим что в etcd

```shell

devops@otus-backend-etcd-1:~$ etcdctl endpoint health --cluster -w=table
+-------------------------+--------+-------------+-------+
|        ENDPOINT         | HEALTH |    TOOK     | ERROR |
+-------------------------+--------+-------------+-------+
| http://10.110.0.30:2379 |   true | 22.858856ms |       |
| http://10.110.0.31:2379 |   true | 27.870168ms |       |
| http://10.110.0.32:2379 |   true | 28.664275ms |       |
+-------------------------+--------+-------------+-------+
devops@otus-backend-etcd-1:~$ etcdctl endpoint status --cluster -w=table
+-------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|        ENDPOINT         |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://10.110.0.31:2379 | 76271b93c57de805 |  3.4.23 |   41 kB |      true |      false |         2 |         46 |                 46 |        |
| http://10.110.0.30:2379 | 9dedb9df17f4d452 |  3.4.23 |   41 kB |     false |      false |         2 |         46 |                 46 |        |
| http://10.110.0.32:2379 | dc96f684ae2bc820 |  3.4.23 |   41 kB |     false |      false |         2 |         46 |                 46 |        |
+-------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

devops@otus-backend-etcd-1:~$ etcdctl get --prefix /
/service/main/config
{"ttl":30,"loop_wait":10,"retry_timeout":10,"check_timeline":true,"maximum_lag_on_failover":1048576,"postgresql":{"use_pg_rewind":true,"remove_data_directory_on_rewind_failure":true,"remove_data_directory_on_diverged_timelines":true,"parameters":{"shared_buffers":"512MB","wal_level":"replica","wal_keep_size":"512MB","max_connections":100,"effective_cache_size":"1GB","maintenance_work_mem":"256MB","max_wal_senders":5,"max_replication_slots":5,"checkpoint_completion_target":0.7,"log_connections":"on","log_disconnections":"on","log_statement":"ddl","log_line_prefix":"%m [%p] %q%u@%d ","logging_collector":"on","log_destination":"stderr","log_directory":"/var/log/postgresql","log_filename":"postgresql-%Y-%m-%d.log","log_rotation_size":"100MB","log_rotation_age":"1d","log_min_duration_statement":-1,"log_min_error_statement":"error","log_min_messages":"warning","log_error_verbosity":"verbose","log_hostname":"off","log_duration":"off","log_timezone":"Europe/Moscow","timezone":"Europe/Moscow","lc_messages":"C.UTF-8","password_encryption":"scram-sha-256","debug_print_parse":"off","debug_print_rewritten":"off","debug_print_plan":"off","superuser_reserved_connections":3,"synchronous_commit":"on","synchronous_standby_names":"*","hot_standby":"on","compute_query_id":"on"},"pg_hba":["local   all             all                                     peer","host    all             all             0.0.0.0/0               md5","host    all             all             127.0.0.1/32            scram-sha-256","host    replication     replicator      127.0.0.1/32            scram-sha-256","host    replication     replicator      ::1/128                 scram-sha-256","host    replication     replicator      10.110.0.0/24           scram-sha-256"]}}
/service/main/initialize
7422262614289738558
/service/main/leader
otus-nodedb-1
/service/main/members/otus-nodedb-1
{"conn_url":"postgres://10.110.0.50:5432/postgres","api_url":"http://10.110.0.50:8008/patroni","state":"running","role":"primary","version":"4.0.1","xlog_location":67333624,"timeline":1}
/service/main/members/otus-nodedb-2
{"conn_url":"postgres://10.110.0.51:5432/postgres","api_url":"http://10.110.0.51:8008/patroni","state":"running","role":"replica","version":"4.0.1","xlog_location":67333624,"replication_state":"streaming","timeline":1}
/service/main/members/otus-nodedb-3
{"conn_url":"postgres://10.110.0.52:5432/postgres","api_url":"http://10.110.0.52:8008/patroni","state":"running","role":"replica","version":"4.0.1","xlog_location":67333624,"replication_state":"streaming","timeline":1}
/service/main/status
{"optime":67333624,"slots":{"otus_nodedb_2":67333624,"otus_nodedb_3":67333624,"otus_nodedb_1":67333624},"retain_slots":["otus_nodedb_1","otus_nodedb_2","otus_nodedb_3"]}

```

Видим что etcd работает - кластер работоспособен - не буду ломать etcd - точно работает)

Заглянем на сервера с postgres 


```shell

root@otus-nodedb-1:/home/devops# patronictl -c /etc/patroni/config.yml list
+ Cluster: main (7422262614289738558) --+-----------+----+-----------+
| Member        | Host        | Role    | State     | TL | Lag in MB |
+---------------+-------------+---------+-----------+----+-----------+
| otus-nodedb-1 | 10.110.0.50 | Leader  | running   |  1 |           |
| otus-nodedb-2 | 10.110.0.51 | Replica | streaming |  1 |         0 |
| otus-nodedb-3 | 10.110.0.52 | Replica | streaming |  1 |         0 |
+---------------+-------------+---------+-----------+----+-----------+
root@otus-nodedb-1:/home/devops# sudo s
sudo: s: command not found
root@otus-nodedb-1:/home/devops# 
root@otus-nodedb-1:/home/devops# su - postgres
postgres@otus-nodedb-1:~$ psql --host=10.110.0.50 --username=postgres
Password for user postgres: 
psql (16.4 (Debian 16.4-1.pgdg120+2))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
Type "help" for help.

postgres=# \list
                                                       List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 postgres  | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(3 rows)

postgres=# \du
                                List of roles
    Role name    |                         Attributes                         
-----------------+------------------------------------------------------------
 postgres        | Superuser, Create role, Create DB, Replication, Bypass RLS
 postgres_rewind | 
 replicator      | Replication

postgres=# exit
postgres@otus-nodedb-1:~$ exit
logout

```
Автоматически базу и пользователя не создавал, чтобы можно было показать в картинках



![alt text](<images/Screenshot from 2024-10-05 15-25-31.png>) 
![alt text](<images/Screenshot from 2024-10-05 15-26-32.png>) 
![alt text](<images/Screenshot from 2024-10-05 15-26-50.png>) 
![alt text](<images/Screenshot from 2024-10-05 15-31-40.png>)


Удаляем файл проверки для инсталяции

```shell

sudo rm /opt/gfsvol/cms/installation/_JoomlaJwexDRtp444AsWwRWH0nR.txt 

```


![alt text](<images/Screenshot from 2024-10-05 15-38-43.png>)
![alt text](<images/Screenshot from 2024-10-05 15-37-21.png>)

Тут техническое замечание - на yc keepalived невозможно заставить работать придется укзхаать в качестве адреса бд один из haproxy 10.110.0.20 вместо 10.110.0.100 - судя по всем потому что режут протокол 112

```shell


root@otus-backend-haproxy-1:/home/devops# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether d0:0d:18:3a:be:73 brd ff:ff:ff:ff:ff:ff
    altname enp138s0
    altname ens8
    inet 10.200.0.20/24 brd 10.200.0.255 scope global dynamic eth0
       valid_lft 4294963070sec preferred_lft 4294963070sec
    inet6 fe80::d20d:18ff:fe3a:be73/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether d0:1d:18:3a:be:73 brd ff:ff:ff:ff:ff:ff
    altname enp139s0
    altname ens9
    inet 10.110.0.20/24 brd 10.110.0.255 scope global dynamic eth1
       valid_lft 4294963071sec preferred_lft 4294963071sec
    inet 10.110.0.100/32 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::d21d:18ff:fe3a:be73/64 scope link 
       valid_lft forever preferred_lft forever
root@otus-backend-haproxy-1:/home/devops# systemctl status keepalived
● keepalived.service - Keepalive Daemon (LVS and VRRP)
     Loaded: loaded (/lib/systemd/system/keepalived.service; enabled; preset: enabled)
     Active: active (running) since Sat 2024-10-05 15:03:17 MSK; 47min ago
       Docs: man:keepalived(8)
             man:keepalived.conf(5)
             man:genhash(1)
             https://keepalived.org
   Main PID: 4213 (keepalived)
      Tasks: 2 (limit: 2305)
     Memory: 3.0M
        CPU: 333ms
     CGroup: /system.slice/keepalived.service
             ├─4213 /usr/sbin/keepalived --dont-fork
             └─4214 /usr/sbin/keepalived --dont-fork

```

![alt text](<images/Screenshot from 2024-10-05 15-35-18.png>)

Ну и сделаем patroni failover


```shell

root@otus-nodedb-1:/home/devops# patronictl -c /etc/patroni/config.yml list
+ Cluster: main (7422262614289738558) --+-----------+----+-----------+
| Member        | Host        | Role    | State     | TL | Lag in MB |
+---------------+-------------+---------+-----------+----+-----------+
| otus-nodedb-1 | 10.110.0.50 | Leader  | running   |  1 |           |
| otus-nodedb-2 | 10.110.0.51 | Replica | streaming |  1 |         0 |
| otus-nodedb-3 | 10.110.0.52 | Replica | streaming |  1 |         0 |
+---------------+-------------+---------+-----------+----+-----------+
root@otus-nodedb-1:/home/devops# patronictl -c /etc/patroni/config.yml failover main
Current cluster topology
+ Cluster: main (7422262614289738558) --+-----------+----+-----------+
| Member        | Host        | Role    | State     | TL | Lag in MB |
+---------------+-------------+---------+-----------+----+-----------+
| otus-nodedb-1 | 10.110.0.50 | Leader  | running   |  1 |           |
| otus-nodedb-2 | 10.110.0.51 | Replica | streaming |  1 |         0 |
| otus-nodedb-3 | 10.110.0.52 | Replica | streaming |  1 |         0 |
+---------------+-------------+---------+-----------+----+-----------+
Candidate ['otus-nodedb-2', 'otus-nodedb-3'] []: otus-nodedb-2
Are you sure you want to failover cluster main, demoting current leader otus-nodedb-1? [y/N]: y
2024-10-05 15:53:22.72387 Successfully failed over to "otus-nodedb-2"
+ Cluster: main (7422262614289738558) --+---------+----+-----------+
| Member        | Host        | Role    | State   | TL | Lag in MB |
+---------------+-------------+---------+---------+----+-----------+
| otus-nodedb-1 | 10.110.0.50 | Replica | stopped |    |   unknown |
| otus-nodedb-2 | 10.110.0.51 | Leader  | running |  1 |           |
| otus-nodedb-3 | 10.110.0.52 | Replica | running |  1 |         0 |
+---------------+-------------+---------+---------+----+-----------+
root@otus-nodedb-1:/home/devops# patronictl -c /etc/patroni/config.yml failover main
Current cluster topology
+ Cluster: main (7422262614289738558) --+---------+----+-----------+
| Member        | Host        | Role    | State   | TL | Lag in MB |
+---------------+-------------+---------+---------+----+-----------+
| otus-nodedb-1 | 10.110.0.50 | Replica | stopped |    |   unknown |
| otus-nodedb-2 | 10.110.0.51 | Leader  | running |  2 |           |
| otus-nodedb-3 | 10.110.0.52 | Replica | running |  1 |         0 |
+---------------+-------------+---------+---------+----+-----------+
root@otus-nodedb-1:/home/devops# patronictl -c /etc/patroni/config.yml list
+ Cluster: main (7422262614289738558) --+-----------+----+-----------+
| Member        | Host        | Role    | State     | TL | Lag in MB |
+---------------+-------------+---------+-----------+----+-----------+
| otus-nodedb-1 | 10.110.0.50 | Replica | streaming |  2 |         0 |
| otus-nodedb-2 | 10.110.0.51 | Leader  | running   |  2 |           |
| otus-nodedb-3 | 10.110.0.52 | Replica | streaming |  2 |         0 |
+---------------+-------------+---------+-----------+----+-----------+
root@otus-nodedb-1:/home/devops# 


```

Видим что лидер сменился

![alt text](<images/Screenshot from 2024-10-05 15-54-42.png>)

## Задание выполнено!




