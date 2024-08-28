# Домашнее задание

## Создать ISCSI + GFS2 + Pacemaker terraform скрипт

### Цель: Реализовать cluster

## Описание/Пошаговая инструкция выполнения домашнего задания:

Необходимо:

1. Реализовать терраформ для разворачивания виртуалки в yandex-cloud

2. Запровиженить nginx с помощью ansible

### Формат сдачи

1. Репозиторий с терраформ манифестами

Критерии оценки:

Преподаватель с помощью terraform apply должен получить развернутый стенд.



```shell

sincere@sincere-ubuntuotus:~/otus/02_highload/lessons/05_1_iscsi_gfs2_pacemaker/ansible$ cat requirements.yml 
---
- src: ondrejhome.targetcli
- src: ondrejhome.targetcli-modules
- src: OndrejHome.iscsiadm

```

`ansible-galaxy install -r requirements.yml`


Good instruction https://www.server-world.info/en/note?os=CentOS_Stream_9&p=pacemaker&f=1