apt install apt-transport-https -y
apt install gnupg2 -y

echo "deb http://elasticrepo.serveradmin.ru bookworm main" | tee /etc/apt/sources.list.d/elasticrepo.list
wget -qO - http://elasticrepo.serveradmin.ru/elastic.asc | apt-key add -
apt update && apt install elasticsearch




systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service


systemctl status elasticsearch.service



- name: Reset elastic user password to random
  ansible.builtin.command: /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b
  register: reset_cmd

- name: Push password
  vars:
    my_password: "{{ reset_cmd.stdout_lines[-1]
      | regex_replace('^New value: (.*)$', '\\1') }}"



curl -k --user elastic:'DrwVWCY-Jd*GhempEHo5' https://127.0.0.1:9200

{
  "name" : "otus-nodeelk-1",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "a5zY2V-jQ6C4KuB9-4cRuQ",
  "version" : {
    "number" : "8.17.0",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "2b6a7fed44faa321997703718f07ee0420804b41",
    "build_date" : "2024-12-11T12:08:05.663969764Z",
    "build_snapshot" : false,
    "lucene_version" : "9.12.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}


cat /etc/elasticsearch/elasticsearch.yml



path.data: /var/lib/elasticsearch # директория для хранения данных
network.host: 127.0.0.1 # слушаем только локальный интерфейс
http.host: 127.0.0.1 # слушаем только локальный интерфейс


nano /etc/elasticsearch/jvm.options.d/mem.options

-Xms2g
-Xmx2g

systemctl restart elasticsearch.service

apt update && apt install kibana


systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service

systemctl status kibana.service

ss -tulnp | grep 5601

cp -R /etc/elasticsearch/certs /etc/kibana
chown -R root:kibana /etc/kibana/certs


/usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system

nano /etc/kibana/kibana.yml

server.host: "0.0.0.0"

elasticsearch.username: "kibana_system"
elasticsearch.password: "mtbg5rIwh*E*eWuBCECG"

elasticsearch.ssl.certificateAuthorities: [ "/etc/kibana/certs/http_ca.crt" ]

И последний момент - указываем подключение к elasticsearch по HTTPS:

elasticsearch.hosts: ["https://localhost:9200"]

Теперь Kibana можно перезапустить:

systemctl restart kibana.service

bastion IP:80

#Logstash

apt install logstash

systemctl enable logstash.service


nano /etc/logstash/conf.d/nginx.conf


input {
  beats {
    port => 5044
  }
}

filter {
 if [type] == "nginx_access" {
    grok {
        match => { "message" => "%{IPORHOST:remote_ip} - %{DATA:user} \[%{HTTPDATE:access_time}\] \"%{WORD:http_method} %{DATA:url} HTTP/%{NUMBER:http_version}\" %{NUMBER:response_code} %{NUMBER:body_sent_bytes} \"%{DATA:referrer}\" \"%{DATA:agent}\"" }
    }
  }
  date {
        match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
  }
  geoip {
         source => "remote_ip"
         target => "geoip"
         add_tag => [ "nginx-geoip" ]
  }
}


output {
        elasticsearch {
            hosts    => "https://localhost:9200"
            index    => "websrv-%{+YYYY.MM}"
	    user => "elastic"
	    password => "DrwVWCY-Jd*GhempEHo5"
	    cacert => "/etc/logstash/certs/http_ca.crt"
        }
}

cp -R /etc/elasticsearch/certs /etc/logstash
chown -R root:logstash /etc/logstash/certs

nano /etc/logstash/conf.d/filter.conf




cp /var/lib/logstash/geoip_database_management/1738342717/GeoLite2-City.mmdb /etc/logstash/

systemctl start logstash.service

/var/log/logstash/logstash-plain.log

#test
nano /etc/logstash/conf.d/logstash.conf

input {
  file {
    path => ["/var/log/logstash/*.log"]
    start_position => "beginning"
  }
}

filter {
  grok {
    match => { "message" => "\[%{TIMESTAMP_ISO8601:timestamp}\]\[%{DATA:severity}%{SPACE}\]\[%{DATA:source}%{SPACE}\]%{SPACE}%{GREEDYDATA:message}" }
    overwrite => [ "message" ]
  }
}

output {
  elasticsearch {
    hosts => ["https://localhost:9200"]
    index => "logstash-logs-%{+YYYY.MM}"
            user => "elastic"
            password => "DrwVWCY-Jd*GhempEHo5"
            cacert => "/etc/logstash/certs/http_ca.crt"
  }
}




#filebeat

echo "deb http://elasticrepo.serveradmin.ru bullseye main" | tee /etc/apt/sources.list.d/elasticrepo.list
wget -qO - http://elasticrepo.serveradmin.ru/elastic.asc | apt-key add -
apt update && apt install filebeat

nano /etc/filebeat/filebeat.yml 


filebeat.inputs:
- type: log
  enabled: true
  paths:
      - /var/log/nginx/*-access.log
  fields:
    type: nginx_access
  fields_under_root: true
  scan_frequency: 5s

- type: log
  enabled: true
  paths:
      - /var/log/nginx/*-error.log
  fields:
    type: nginx_error
  fields_under_root: true
  scan_frequency: 5s

output.logstash:
  hosts: ["10.100.0.150:5044"]

xpack.monitoring:
  enabled: true
  elasticsearch:
    hosts: ["http://10.100.0.150:9200"]
