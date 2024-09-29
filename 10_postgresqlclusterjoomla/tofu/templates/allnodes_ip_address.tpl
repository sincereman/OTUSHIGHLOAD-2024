---
# nodes_vars_ip

allnodes_ip_address:
%{ for index, name in frontend_name ~}
  - name: ${name}
    ip: ${frontend_internal_ip_web[index]}
    int: web
%{ endfor ~}
%{ for index, name in nodeweb_name ~}
  - name: ${name}
    ip: ${nodeweb_internal_ip_web[index]}
    int: web
#  - name: ${name}
#    ip: ${nodeweb_internal_ip_db[index]}
#     int: db
%{ endfor ~}
%{ for index, name in nodedb_name ~}
  - name: ${name}
    ip: ${nodedb_internal_ip_db[index]}
    int: db
%{ endfor ~}
%{ for index, name in nodehaproxybackend_name ~}
  - name: ${name}
    ip: ${nodehaproxybackend_internal_ip_db[index]}
    int: db    
%{ endfor ~}
%{ for index, name in nodeetcdbackend_name ~}
  - name: ${name}
    ip: ${nodeetcdbackend_internal_ip_db[index]}
    int: db
%{ endfor ~}