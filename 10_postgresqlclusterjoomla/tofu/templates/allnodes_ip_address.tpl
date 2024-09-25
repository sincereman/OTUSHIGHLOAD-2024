---
# nodes_vars_ip

allnodes_ip_address:
%{ for index, name in frontend_name ~}
  - name: ${name}-web
    ip: ${frontend_internal_ip_web[index]}
%{ endfor ~}
%{ for index, name in nodeweb_name ~}
  - name: ${name}-web
    ip: ${nodeweb_internal_ip_web[index]}
#  - name: ${name}-db
#    ip: ${nodeweb_internal_ip_db[index]}
%{ endfor ~}
%{ for index, name in nodedb_name ~}
  - name: ${name}-db
    ip: ${nodedb_internal_ip_db[index]}
%{ endfor ~}
%{ for index, name in nodehaproxybackend_name ~}
  - name: ${name}-db
    ip: ${nodehaproxybackend_internal_ip_db[index]}
%{ endfor ~}
%{ for index, name in nodeetcdbackend_name ~}
  - name: ${name}-db
    ip: ${nodeetcdbackend_internal_ip_db[index]}
%{ endfor ~}